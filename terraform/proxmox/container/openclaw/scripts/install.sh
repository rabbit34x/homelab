#!/bin/bash
set -euo pipefail

echo "=== OpenClaw セットアップ ==="

# 1. システム更新と依存パッケージ
echo "[1/4] システム更新..."
apt update && apt upgrade -y
apt install -y curl unzip git

# 2. Bun ランタイム（OpenClaw に必要）
echo "[2/4] Bun インストール..."
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

# .env 雛形の作成
if [ ! -f /root/.openclaw/.env ]; then
  mkdir -p /root/.openclaw
  cat > /root/.openclaw/.env << 'ENVEOF'
ANTHROPIC_API_KEY=
DISCORD_BOT_TOKEN_LULU=
DISCORD_BOT_TOKEN_SAYA=
DISCORD_GUILD_ID=
DISCORD_CHANNEL_ID=
DISCORD_USER_ID=
GATEWAY_AUTH_TOKEN=
GITHUB_PAT=
ENVEOF
fi

echo ""
echo "=== インストール完了 ==="
