#!/bin/bash
# ローカルマシンから実行するデプロイスクリプト
# openclaw-config の内容をコンテナに転送し、Gateway を再起動する
set -euo pipefail

SSH_KEY="${SSH_KEY:-$HOME/.ssh/proxmox}"
SSH_HOST="${SSH_HOST:-root@192.168.0.113}"
CONFIG_REPO="$HOME/src/github.com/rabbit34x/openclaw-config"
REMOTE_DIR="/root/.openclaw"

if [ ! -d "$CONFIG_REPO" ]; then
  echo "Error: $CONFIG_REPO が見つかりません"
  exit 1
fi

echo "=== OpenClaw デプロイ ==="

# 1. ローカルリポジトリを最新に
echo "[1/3] openclaw-config を pull..."
git -C "$CONFIG_REPO" pull

# 2. SCP でコンテナに転送
echo "[2/3] ワークスペースを転送中..."
scp -i "$SSH_KEY" -r "$CONFIG_REPO/workspace-lulu/"* "$SSH_HOST:$REMOTE_DIR/workspace-lulu/"
scp -i "$SSH_KEY" -r "$CONFIG_REPO/workspace-saya/"* "$SSH_HOST:$REMOTE_DIR/workspace-saya/"
echo "  workspace-lulu: 転送完了"
echo "  workspace-saya: 転送完了"

# 3. Gateway 再起動
echo "[3/3] Gateway を再起動中..."
ssh -i "$SSH_KEY" "$SSH_HOST" "openclaw-restart"

echo ""
echo "=== デプロイ完了 ==="
