#!/bin/bash
set -euo pipefail

ENV_FILE="/root/.openclaw/.env"

if [ ! -f "$ENV_FILE" ]; then
  echo "Error: $ENV_FILE が見つかりません"
  echo "以下の形式で作成してください:"
  echo '  ANTHROPIC_API_KEY=sk-ant-...'
  exit 1
fi

source "$ENV_FILE"

if [ -z "${ANTHROPIC_API_KEY:-}" ]; then
  echo "Error: ANTHROPIC_API_KEY が .env に設定されていません"
  exit 1
fi

# 既に起動中か確認
if pgrep -f "openclaw-gateway" > /dev/null 2>&1; then
  echo "Error: openclaw gateway が既に起動しています"
  echo "先に stop.sh を実行してください"
  exit 1
fi

echo "=== Gateway 起動 ==="

# ルル（Anthropic Claude）
echo "ルル (anthropic) を起動中..."
ANTHROPIC_API_KEY="$ANTHROPIC_API_KEY" \
OPENCLAW_STATE_DIR=/root/.openclaw/state-lulu \
OPENCLAW_CONFIG_PATH=/root/.openclaw/gateway-lulu/openclaw.json \
  nohup openclaw gateway > /tmp/gateway-lulu.log 2>&1 &
LULU_PID=$!

sleep 3

# 紗夜（OpenAI Codex）
echo "紗夜 (codex) を起動中..."
OPENCLAW_STATE_DIR=/root/.openclaw/state-saya \
OPENCLAW_CONFIG_PATH=/root/.openclaw/gateway-saya/openclaw.json \
  nohup openclaw gateway > /tmp/gateway-saya.log 2>&1 &
SAYA_PID=$!

sleep 5

# 起動確認
echo ""
if ps -p "$LULU_PID" > /dev/null 2>&1; then
  echo "ルル: 起動済み (PID: $LULU_PID)"
else
  echo "ルル: 起動失敗 — ログ: /tmp/gateway-lulu.log"
fi

if ps -p "$SAYA_PID" > /dev/null 2>&1; then
  echo "紗夜: 起動済み (PID: $SAYA_PID)"
else
  echo "紗夜: 起動失敗 — ログ: /tmp/gateway-saya.log"
fi
