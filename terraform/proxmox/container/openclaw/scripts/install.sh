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
echo "[3/4] OpenClaw インストール..."
curl -fsSL https://openclaw.ai/install.sh | bash
echo 'export PATH="$HOME/.openclaw/bin:$PATH"' >> ~/.bashrc
export PATH="$HOME/.openclaw/bin:$PATH"

# 4. 運用スクリプトのインストール
echo "[4/4] 運用スクリプトのインストール..."
SCRIPTS_URL="https://raw.githubusercontent.com/rabbit34x/homelab/main/terraform/proxmox/container/openclaw/scripts"
mkdir -p /usr/local/bin
for script in start.sh stop.sh restart.sh; do
  curl -fsSL "$SCRIPTS_URL/$script" -o "/usr/local/bin/openclaw-${script%.sh}"
  chmod +x "/usr/local/bin/openclaw-${script%.sh}"
done
echo "  インストール済み: openclaw-start, openclaw-stop, openclaw-restart"

# .env 雛形の作成
if [ ! -f /root/.openclaw/.env ]; then
  mkdir -p /root/.openclaw
  cat > /root/.openclaw/.env << 'ENVEOF'
ANTHROPIC_API_KEY=<YOUR_ANTHROPIC_API_KEY>
ENVEOF
  echo "  .env 雛形を作成: /root/.openclaw/.env"
fi

echo ""
echo "=== インストール完了 ==="
echo ""
echo "次のステップ（手動）:"
echo "  1. source ~/.bashrc"
echo "  2. /root/.openclaw/.env に ANTHROPIC_API_KEY を設定"
echo "  3. Codex OAuth の認証: openclaw models auth login --provider openai-codex"
echo "  4. ローカルから deploy.sh で設定ファイルを配置・起動"
