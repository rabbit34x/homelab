# OpenClaw

## 事前準備

初セットアップ前に以下を用意する。

| 項目 | 取得先 | 用途 |
|------|--------|------|
| SSH鍵 | ローカルに作成（例: `~/.ssh/proxmox`） | コンテナへのアクセス |
| Anthropic API Key | console.anthropic.com または Claude Code OAuth | ルルの LLM 認証 |
| ChatGPT アカウント | openai.com | 紗夜の Codex OAuth 認証 |
| Discord Bot トークン x2 | Discord Developer Portal | ルル用・紗夜用 |
| Discord サーバーID | Discord 開発者モードで右クリック → IDをコピー | Gateway設定 |
| Discord チャンネルID | 同上 | Gateway設定 |
| Discord ユーザーID | 同上 | Gateway設定 |
| Gateway認証トークン | 任意の文字列を自分で決める | Gateway API認証 |

## 初期セットアップ

### 1. LXCコンテナ作成

```bash
cd terraform/proxmox/container/openclaw
terraform apply
```

### 2. install.sh の実行

コンテナにSSHログインし、セットアップスクリプトを実行：

```bash
ssh -i ~/.ssh/proxmox root@192.168.0.113
curl -fsSL https://raw.githubusercontent.com/rabbit34x/homelab/main/terraform/proxmox/container/openclaw/scripts/install.sh | bash
source ~/.bashrc
```

Bun、OpenClaw、運用スクリプト（`openclaw-start` / `openclaw-stop` / `openclaw-restart`）がインストールされる。

### 3. 認証

コンテナ上で実行する。

#### Anthropic API Key

```bash
mkdir -p /root/.openclaw
cat > /root/.openclaw/.env << 'EOF'
ANTHROPIC_API_KEY=<YOUR_ANTHROPIC_API_KEY>
EOF
```

#### Codex OAuth

```bash
openclaw models auth login --provider openai-codex
```

ブラウザ認証。ChatGPTアカウントでログインする。リモート環境の場合はURLをローカルブラウザで開き、リダイレクトURLをターミナルに貼り付ける。

### 4. Discord Bot の作成

Discord Developer Portal (https://discord.com/developers/applications) で2つのアプリケーションを作成：

1. **ルル用Bot** — Bot作成 → トークン取得 → Message Content Intent 有効化
2. **紗夜用Bot** — 同上

OAuth2 URL Generator でサーバーに招待：
- Scopes: `bot`, `applications.commands`
- Permissions: View Channels, Send Messages, Read Message History, Embed Links, Attach Files, Add Reactions, Manage Channels

### 5. Gateway設定の配置

コンテナ上で実行する。

```bash
# openclaw-config からテンプレートをコピー（ローカルからSCPでも可）
git clone https://github.com/rabbit34x/openclaw-config.git /tmp/openclaw-config

mkdir -p ~/.openclaw/gateway-lulu ~/.openclaw/gateway-saya
cp /tmp/openclaw-config/gateway-lulu/openclaw.json ~/.openclaw/gateway-lulu/openclaw.json
cp /tmp/openclaw-config/gateway-saya/openclaw.json ~/.openclaw/gateway-saya/openclaw.json

rm -rf /tmp/openclaw-config
```

各 `openclaw.json` のプレースホルダーを実際の値に置き換える：

| プレースホルダー | 説明 |
|-----------------|------|
| `<DISCORD_BOT_TOKEN_LULU>` | ルル用Discordボットトークン |
| `<DISCORD_BOT_TOKEN_SAYA>` | 紗夜用Discordボットトークン |
| `<DISCORD_GUILD_ID>` | DiscordサーバーID |
| `<DISCORD_CHANNEL_ID>` | DiscordチャンネルID |
| `<DISCORD_USER_ID>` | あなたのDiscordユーザーID |
| `<GATEWAY_AUTH_TOKEN>` | Gateway認証トークン（任意の文字列） |

### 6. ワークスペースの配置

ローカルマシンから `deploy.sh` を実行：

```bash
./deploy.sh
```

openclaw-config リポジトリからワークスペースファイル（SOUL.md, IDENTITY.md 等）を転送し、Gatewayを起動する。

### 7. 状態ディレクトリの作成

コンテナ上で実行する。2つのGatewayがセッションロックで競合しないよう分離する：

```bash
mkdir -p ~/.openclaw/state-lulu ~/.openclaw/state-saya
```

紗夜のCodex OAuth認証情報を状態ディレクトリにコピー：

```bash
mkdir -p ~/.openclaw/state-saya/agents/main/agent
cp ~/.openclaw/agents/main/agent/auth-profiles.json ~/.openclaw/state-saya/agents/main/agent/
```

### 8. 起動

```bash
openclaw-start
```

---

## 運用

### 設定ファイル一覧

| ファイル | パス (コンテナ上) | 内容 |
|---------|------------------|------|
| `.env` | `/root/.openclaw/.env` | `ANTHROPIC_API_KEY` |
| ルル Gateway設定 | `/root/.openclaw/gateway-lulu/openclaw.json` | モデル、Discord、ポート等 |
| 紗夜 Gateway設定 | `/root/.openclaw/gateway-saya/openclaw.json` | モデル、Discord、ポート等 |
| ルル ワークスペース | `/root/.openclaw/workspace-lulu/` | SOUL.md, IDENTITY.md, AGENTS.md, USER.md |
| 紗夜 ワークスペース | `/root/.openclaw/workspace-saya/` | 同上 |

### 操作一覧

ローカルマシンから実行する。

```bash
SSH_TARGET="-i ~/.ssh/proxmox root@192.168.0.113"
```

| 操作 | コマンド |
|------|---------|
| 起動 | `ssh $SSH_TARGET openclaw-start` |
| 停止 | `ssh $SSH_TARGET openclaw-stop` |
| 再起動 | `ssh $SSH_TARGET openclaw-restart` |
| ワークスペースデプロイ | ローカルで `deploy.sh` を実行 |
| Gateway設定変更 | `ssh $SSH_TARGET` でログインし `openclaw.json` を編集 → `openclaw-restart` |
| ログ確認（ルル） | `ssh $SSH_TARGET "tail /tmp/gateway-lulu.log"` |
| ログ確認（紗夜） | `ssh $SSH_TARGET "tail /tmp/gateway-saya.log"` |
