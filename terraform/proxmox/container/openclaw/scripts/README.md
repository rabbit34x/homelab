# OpenClaw セットアップ

## 1. install.sh の実行

コンテナにSSHログイン後：

```bash
ssh root@192.168.0.113
curl -fsSL https://raw.githubusercontent.com/rabbit34x/homelab/main/terraform/proxmox/container/openclaw/scripts/install.sh | bash
source ~/.bashrc
```

## 2. 認証

### Claude Code CLI

```bash
claude login
```

ブラウザ認証が求められる。リモート環境の場合はURLをローカルブラウザで開き、リダイレクトURLをターミナルに貼り付ける。

### Codex OAuth

```bash
openclaw models auth login --provider openai-codex
```

同様にブラウザ認証。ChatGPTアカウントでログインする。

## 3. Claude Max API Proxy の起動確認

```bash
claude-max-api &
curl http://localhost:3456/health
```

## 4. Discord Bot の作成

Discord Developer Portal (https://discord.com/developers/applications) で2つのアプリケーションを作成：

1. **ルル用Bot** — Bot作成 → トークン取得 → Message Content Intent 有効化
2. **紗夜用Bot** — 同上

OAuth2 URL Generator でサーバーに招待：
- Scopes: `bot`, `applications.commands`
- Permissions: View Channels, Send Messages, Read Message History, Embed Links, Attach Files, Add Reactions, Manage Channels

## 5. 設定ファイルの配置

openclaw-config リポジトリからワークスペースファイルを配置：

```bash
git clone https://github.com/rabbit34x/openclaw-config.git /tmp/openclaw-config

# ルル
cp -r /tmp/openclaw-config/workspace-lulu/* ~/.openclaw/workspace-lulu/

# 紗夜
cp -r /tmp/openclaw-config/workspace-saya/* ~/.openclaw/workspace-saya/

# Gateway 設定
cp /tmp/openclaw-config/gateway-lulu/openclaw.json ~/.openclaw/gateway-lulu/openclaw.json
cp /tmp/openclaw-config/gateway-saya/openclaw.json ~/.openclaw/gateway-saya/openclaw.json
```

各 `openclaw.json` のプレースホルダーを実際の値に置き換える：
- `<DISCORD_BOT_TOKEN_LULU>` / `<DISCORD_BOT_TOKEN_SAYA>`
- `<YOUR_DISCORD_USER_ID>`
- `<YOUR_GUILD_ID>`

## 6. Gateway の起動

```bash
# ルル（Claude）
OPENCLAW_CONFIG=~/.openclaw/gateway-lulu/openclaw.json openclaw gateway &

# 紗夜（Codex）
OPENCLAW_CONFIG=~/.openclaw/gateway-saya/openclaw.json openclaw gateway &
```
