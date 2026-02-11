#!/bin/bash
set -euo pipefail

echo "=== Gateway 停止 ==="

PIDS=$(pgrep -f "openclaw-gateway" 2>/dev/null || true)

if [ -z "$PIDS" ]; then
  echo "起動中の gateway はありません"
  exit 0
fi

echo "停止中: $PIDS"
kill $PIDS 2>/dev/null || true

sleep 2

# 確認
REMAINING=$(pgrep -f "openclaw-gateway" 2>/dev/null || true)
if [ -z "$REMAINING" ]; then
  echo "全 gateway を停止しました"
else
  echo "Warning: まだ残っているプロセスがあります: $REMAINING"
  echo "強制停止するには: kill -9 $REMAINING"
fi
