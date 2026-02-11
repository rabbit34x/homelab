#!/bin/bash
# ローカルマシンから実行するデプロイスクリプト
# openclaw-config の内容をコンテナに転送し、Gateway を再起動する
set -euo pipefail

SSH_KEY="${SSH_KEY:-$HOME/.ssh/proxmox}"
SSH_HOST="${SSH_HOST:-root@192.168.0.113}"
CONFIG_REPO="$HOME/src/github.com/rabbit34x/openclaw-config"
REMOTE_DIR="/root/.openclaw"
REMOTE_ENV="$REMOTE_DIR/.env"

if [ ! -d "$CONFIG_REPO" ]; then
  echo "Error: $CONFIG_REPO が見つかりません"
  exit 1
fi

echo "=== OpenClaw デプロイ ==="

# 1. ローカルリポジトリを最新に
echo "[1/4] openclaw-config を pull..."
git -C "$CONFIG_REPO" pull

# 2. ワークスペースを転送
echo "[2/4] ワークスペースを転送中..."
scp -i "$SSH_KEY" -r "$CONFIG_REPO/workspace-lulu/"* "$SSH_HOST:$REMOTE_DIR/workspace-lulu/"
scp -i "$SSH_KEY" -r "$CONFIG_REPO/workspace-saya/"* "$SSH_HOST:$REMOTE_DIR/workspace-saya/"
echo "  workspace-lulu: 転送完了"
echo "  workspace-saya: 転送完了"

# 3. Gateway設定をテンプレートから生成して転送
echo "[3/4] Gateway設定を転送中..."
TMPDIR=$(mktemp -d)
trap "rm -rf $TMPDIR" EXIT

# .env の値を取得
ENV_VALUES=$(ssh -i "$SSH_KEY" "$SSH_HOST" "cat $REMOTE_ENV")

for bot in lulu saya; do
  cp "$CONFIG_REPO/gateway-$bot/openclaw.json" "$TMPDIR/openclaw-$bot.json"

  # .env の各行でプレースホルダーを置換
  while IFS='=' read -r key value; do
    [ -z "$key" ] && continue
    [[ "$key" =~ ^# ]] && continue
    placeholder="<$key>"
    sed -i "s|$placeholder|$value|g" "$TMPDIR/openclaw-$bot.json"
  done <<< "$ENV_VALUES"

  scp -i "$SSH_KEY" "$TMPDIR/openclaw-$bot.json" "$SSH_HOST:$REMOTE_DIR/gateway-$bot/openclaw.json"
  echo "  gateway-$bot: 転送完了"
done

# 4. Gateway 再起動
echo "[4/4] Gateway を再起動中..."
ssh -i "$SSH_KEY" "$SSH_HOST" "openclaw-restart"

echo ""
echo "=== デプロイ完了 ==="
