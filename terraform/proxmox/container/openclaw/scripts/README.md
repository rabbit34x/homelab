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

### 3. シークレットの設定

コンテナ上で `/root/.openclaw/.env` を編集する（install.sh で雛形が作成済み）：

```bash
vi /root/.openclaw/.env
```

| 変数名 | 説明 |
|--------|------|
| `ANTHROPIC_API_KEY` | Anthropic API キー |
| `DISCORD_BOT_TOKEN_LULU` | ルル用Discordボットトークン |
| `DISCORD_BOT_TOKEN_SAYA` | 紗夜用Discordボットトークン |
| `DISCORD_GUILD_ID` | DiscordサーバーID |
| `DISCORD_CHANNEL_ID` | DiscordチャンネルID |
| `DISCORD_USER_ID` | あなたのDiscordユーザーID |
| `GATEWAY_AUTH_TOKEN` | Gateway認証トークン（任意の文字列） |

### 4. Codex OAuth

コンテナ上で実行する：

```bash
openclaw models auth login --provider openai-codex
```

ブラウザ認証。ChatGPTアカウントでログインする。リモート環境の場合はURLをローカルブラウザで開き、リダイレクトURLをターミナルに貼り付ける。

### 5. Discord Bot の作成

Discord Developer Portal (https://discord.com/developers/applications) で2つのアプリケーションを作成：

1. **ルル用Bot** — Bot作成 → トークン取得 → Message Content Intent 有効化
2. **紗夜用Bot** — 同上

OAuth2 URL Generator でサーバーに招待：
- Scopes: `bot`, `applications.commands`
- Permissions: View Channels, Send Messages, Read Message History, Embed Links, Attach Files, Add Reactions, Manage Channels

取得したトークンを手順3の `.env` に記入する。

### 6. 状態ディレクトリの作成

コンテナ上で実行する。2つのGatewayがセッションロックで競合しないよう分離する：

```bash
mkdir -p ~/.openclaw/state-lulu ~/.openclaw/state-saya
```

紗夜のCodex OAuth認証情報を状態ディレクトリにコピー：

```bash
mkdir -p ~/.openclaw/state-saya/agents/main/agent
cp ~/.openclaw/agents/main/agent/auth-profiles.json ~/.openclaw/state-saya/agents/main/agent/
```

### 7. デプロイ・起動

ローカルマシンから `deploy.sh` を実行：

```bash
./deploy.sh
```

openclaw-config リポジトリからワークスペース・Gateway設定を転送し、`.env` の値でプレースホルダーを自動置換して、Gatewayを起動する。

---

## 運用

### 設定ファイル一覧

| ファイル | パス (コンテナ上) | 内容 |
|---------|------------------|------|
| `.env` | `/root/.openclaw/.env` | 全シークレット（APIキー、Discordトークン、ID等） |
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
| 全設定デプロイ | ローカルで `deploy.sh` を実行 |
| ログ確認（ルル） | `ssh $SSH_TARGET "tail /tmp/gateway-lulu.log"` |
| ログ確認（紗夜） | `ssh $SSH_TARGET "tail /tmp/gateway-saya.log"` |
