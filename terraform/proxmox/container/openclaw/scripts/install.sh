#!/bin/bash
set -euo pipefail

echo "=== OpenClaw セットアップ ==="

# 1. システム更新と依存パッケージ
echo "[1/5] システム更新..."
apt update && apt upgrade -y
apt install -y curl unzip git

# 2. Bun ランタイム（OpenClaw に必要）
echo "[2/5] Bun インストール..."
curl -fsSL https://bun.sh/install | bash
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
echo 'export BUN_INSTALL="$HOME/.bun"' >> ~/.bashrc
echo 'export PATH="$BUN_INSTALL/bin:$PATH"' >> ~/.bashrc
bun --version

# 3. Node.js 22（Claude Max API Proxy に必要）
echo "[3/5] Node.js インストール..."
curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
apt install -y nodejs
node --version
npm --version

# 4. OpenClaw
echo "[4/5] OpenClaw インストール..."
curl -fsSL https://openclaw.ai/install.sh | bash
echo 'export PATH="$HOME/.openclaw/bin:$PATH"' >> ~/.bashrc
export PATH="$HOME/.openclaw/bin:$PATH"

# 5. Claude Max API Proxy
echo "[5/5] Claude Max API Proxy インストール..."
npm install -g claude-max-api-proxy

echo ""
echo "=== インストール完了 ==="
echo ""
echo "次のステップ（手動）:"
echo "  1. source ~/.bashrc"
echo "  2. Claude Code CLI の認証: claude login"
echo "  3. Codex OAuth の認証: openclaw models auth login --provider openai-codex"
echo "  4. Discord Bot トークンの設定（openclaw.json を編集）"
echo "  5. ワークスペースファイルの配置"
echo "  6. Gateway の起動"
