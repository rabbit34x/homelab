#!/bin/bash
set -euo pipefail

REPO_URL="https://github.com/rabbit34x/openclaw-config.git"
TMP_DIR="/tmp/openclaw-config"
OPENCLAW_DIR="/root/.openclaw"

echo "=== OpenClaw デプロイ ==="

# 1. リポジトリ取得
echo "[1/3] openclaw-config を取得中..."
rm -rf "$TMP_DIR"
git clone --depth 1 "$REPO_URL" "$TMP_DIR"

# 2. ワークスペースファイルの更新
echo "[2/3] ワークスペースを更新中..."
cp -r "$TMP_DIR/workspace-lulu/"* "$OPENCLAW_DIR/workspace-lulu/"
cp -r "$TMP_DIR/workspace-saya/"* "$OPENCLAW_DIR/workspace-saya/"
echo "  workspace-lulu: 更新完了"
echo "  workspace-saya: 更新完了"

# 3. Gateway 再起動
echo "[3/3] Gateway を再起動中..."
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
"$SCRIPT_DIR/restart.sh"

# クリーンアップ
rm -rf "$TMP_DIR"

echo ""
echo "=== デプロイ完了 ==="
