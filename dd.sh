#!/bin/bash
# 专用 Debian 一键重装脚本（已预置 BBR+FQ_PIE + sing-box）
# 使用方法：
#   bash <(curl -sL https://debian.526627.xyz/dd.sh)
#   bash <(curl -sL https://debian.526627.xyz/dd.sh) 自定义密码

set -e

# ===================== 配置 =====================
IMAGE_URL="https://github.com/MhGot/debian-image/releases/download/v1.0/debian12-bbr-singbox.raw.xz"
DEFAULT_PASSWORD="Dawn11.."
# ===============================================

PASSWORD="${1:-$DEFAULT_PASSWORD}"

clear
echo "========================================"
echo " 自定义 Debian 一键重装"
echo " 镜像：$IMAGE_URL"
echo " root 密码：$PASSWORD"
echo "========================================"
echo
echo "警告：此操作会清空当前硬盘所有数据！"
echo "直接按回车继续，或输入 n 取消"
read -p "请确认: " confirm

# 回车或空内容继续，输入 n/N 取消
if [[ "$confirm" == "n" || "$confirm" == "N" ]]; then
  echo "已取消"
  exit 1
fi

echo
echo "开始重装，请耐心等待（过程中会自动重启）..."
echo "----------------------------------------"

# 调用上游重装脚本，并尽量减少多余输出
bash <(curl -sL https://raw.githubusercontent.com/bin456789/reinstall/main/reinstall.sh) \
  --image "$IMAGE_URL" \
  --password "$PASSWORD"
