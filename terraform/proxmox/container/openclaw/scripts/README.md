# OpenClaw セットアップ

## 1. install.sh の実行

コンテナにSSHログイン後：

```bash
ssh root@192.168.0.113
curl -fsSL https://raw.githubusercontent.com/rabbit34x/homelab/main/terraform/proxmox/container/openclaw/scripts/install.sh | bash
source ~/.bashrc
```

## 2. 認証

### Codex OAuth

```bash
openclaw models auth login --provider openai-codex
```

ブラウザ認証。ChatGPTアカウントでログインする。リモート環境の場合はURLをローカルブラウザで開き、リダイレクトURLをターミナルに貼り付ける。

### Anthropic API Key

ルルは `ANTHROPIC_API_KEY` 環境変数で認証する。起動時に指定する（手順6参照）。

## 3. Discord Bot の作成

Discord Developer Portal (https://discord.com/developers/applications) で2つのアプリケーションを作成：

1. **ルル用Bot** — Bot作成 → トークン取得 → Message Content Intent 有効化
2. **紗夜用Bot** — 同上

OAuth2 URL Generator でサーバーに招待：
- Scopes: `bot`, `applications.commands`
- Permissions: View Channels, Send Messages, Read Message History, Embed Links, Attach Files, Add Reactions, Manage Channels

## 4. 設定ファイルの配置

openclaw-config リポジトリからワークスペース・Gateway設定を配置：

```bash
git clone https://github.com/rabbit34x/openclaw-config.git /tmp/openclaw-config

# ワークスペース
cp -r /tmp/openclaw-config/workspace-lulu/* ~/.openclaw/workspace-lulu/
cp -r /tmp/openclaw-config/workspace-saya/* ~/.openclaw/workspace-saya/

# Gateway 設定
mkdir -p ~/.openclaw/gateway-lulu ~/.openclaw/gateway-saya
cp /tmp/openclaw-config/gateway-lulu/openclaw.json ~/.openclaw/gateway-lulu/openclaw.json
cp /tmp/openclaw-config/gateway-saya/openclaw.json ~/.openclaw/gateway-saya/openclaw.json
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

## 5. 状態ディレクトリの作成

2つのGatewayがセッションロックで競合しないよう、状態ディレクトリを分離する：

```bash
mkdir -p ~/.openclaw/state-lulu ~/.openclaw/state-saya
```

紗夜のCodex OAuth認証情報を状態ディレクトリにコピー：

```bash
mkdir -p ~/.openclaw/state-saya/agents/main/agent
cp ~/.openclaw/agents/main/agent/auth-profiles.json ~/.openclaw/state-saya/agents/main/agent/
```

## 6. Gateway の起動

```bash
# ルル（Anthropic Claude）
ANTHROPIC_API_KEY="<YOUR_ANTHROPIC_API_KEY>" \
OPENCLAW_STATE_DIR=~/.openclaw/state-lulu \
OPENCLAW_CONFIG_PATH=~/.openclaw/gateway-lulu/openclaw.json \
  nohup openclaw gateway > /tmp/gateway-lulu.log 2>&1 &

# 紗夜（OpenAI Codex）
OPENCLAW_STATE_DIR=~/.openclaw/state-saya \
OPENCLAW_CONFIG_PATH=~/.openclaw/gateway-saya/openclaw.json \
  nohup openclaw gateway > /tmp/gateway-saya.log 2>&1 &
```
