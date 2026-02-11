#!/bin/bash
set -euo pipefail

echo "=== OpenClaw セットアップ ==="

# 1. システム更新と依存パッケージ
echo "[1/3] システム更新..."
apt update && apt upgrade -y
apt install -y curl unzip git

# 2. Bun ランタイム（OpenClaw に必要）
echo "[2/3] Bun インストール..."
curl -fsSL https://bun.sh/install | bash
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
echo 'export BUN_INSTALL="$HOME/.bun"' >> ~/.bashrc
echo 'export PATH="$BUN_INSTALL/bin:$PATH"' >> ~/.bashrc
bun --version

# 3. OpenClaw
echo "[3/3] OpenClaw インストール..."
curl -fsSL https://openclaw.ai/install.sh | bash
echo 'export PATH="$HOME/.openclaw/bin:$PATH"' >> ~/.bashrc
export PATH="$HOME/.openclaw/bin:$PATH"

echo ""
echo "=== インストール完了 ==="
echo ""
echo "次のステップ（手動）:"
echo "  1. source ~/.bashrc"
echo "  2. Codex OAuth の認証: openclaw models auth login --provider openai-codex"
echo "  3. Discord Bot トークンの設定（openclaw.json を編集）"
echo "  4. ワークスペースファイルの配置"
echo "  5. Gateway の起動"
