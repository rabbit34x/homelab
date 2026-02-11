# OpenClaw セットアップ

## 1. コンテナ作成

```bash
cd terraform/proxmox/container/openclaw
terraform apply
```

## 2. インストール

```bash
ssh -i ~/.ssh/proxmox root@192.168.0.113
curl -fsSL https://raw.githubusercontent.com/rabbit34x/homelab/main/terraform/proxmox/container/openclaw/scripts/install.sh | bash
source ~/.bashrc
```

## 3. シークレット設定

```bash
vi /root/.openclaw/.env
```

```
ANTHROPIC_API_KEY=sk-ant-...
DISCORD_BOT_TOKEN_LULU=MTQ3...
DISCORD_BOT_TOKEN_SAYA=MTQ3...
DISCORD_GUILD_ID=3133...
DISCORD_CHANNEL_ID=3133...
DISCORD_USER_ID=1997...
GATEWAY_AUTH_TOKEN=<任意の文字列>
GITHUB_PAT=github_pat_...
```

## 4. Codex OAuth

```bash
openclaw models auth login --provider openai-codex
```

## 5. Discord Bot 作成

Discord Developer Portal で2つのBot作成。それぞれ Message Content Intent を有効化しサーバーに招待。

## 6. リポジトリのclone

```bash
source /root/.openclaw/.env
git clone https://${GITHUB_PAT}@github.com/rabbit34x/openclaw-config.git /root/.openclaw/openclaw-config
cd /root/.openclaw/openclaw-config
git config user.name "openclaw-bot"
git config user.email "openclaw-bot@noreply"
```

## 7. Gateway設定の生成

```bash
source /root/.openclaw/.env
for bot in lulu saya; do
  mkdir -p /root/.openclaw/gateway-$bot
  cp /root/.openclaw/openclaw-config/gateway-$bot/openclaw.json /root/.openclaw/gateway-$bot/openclaw.json
  while IFS='=' read -r key value; do
    [ -z "$key" ] && continue
    sed -i "s|<$key>|$value|g" /root/.openclaw/gateway-$bot/openclaw.json
  done < /root/.openclaw/.env
done
```

## 8. 状態ディレクトリ作成

```bash
mkdir -p /root/.openclaw/state-lulu /root/.openclaw/state-saya
mkdir -p /root/.openclaw/state-saya/agents/main/agent
cp /root/.openclaw/agents/main/agent/auth-profiles.json /root/.openclaw/state-saya/agents/main/agent/
```

## 9. 起動

```bash
openclaw-start
```

---

## 運用

```bash
SSH_TARGET="-i ~/.ssh/proxmox root@192.168.0.113"
```

| 操作 | コマンド |
|------|---------|
| 起動 | `ssh $SSH_TARGET openclaw-start` |
| 停止 | `ssh $SSH_TARGET openclaw-stop` |
| 再起動 | `ssh $SSH_TARGET openclaw-restart` |
| ワークスペース更新 | `ssh $SSH_TARGET "cd /root/.openclaw/openclaw-config && git pull"` |
| ログ確認（ルル） | `ssh $SSH_TARGET "tail /tmp/gateway-lulu.log"` |
| ログ確認（紗夜） | `ssh $SSH_TARGET "tail /tmp/gateway-saya.log"` |
