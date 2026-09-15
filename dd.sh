#!/bin/bash
# 专用 Debian 一键重装脚本（已预置 BBR+FQ_PIE + sing-box）
# 使用方法：
#   bash <(curl -sL https://debian.526627.xyz/dd.sh)
#   bash <(curl -sL https://debian.526627.xyz/dd.sh) 自定义密码

set -e

# ===================== 配置 =====================
IMAGE_URL="http://144.24.86.236:8034/api/shares/pTYHDAy8/files/34bb278a-a76e-4862-8936-362142d531b5"
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

if [[ "$confirm" == "n" || "$confirm" == "N" ]]; then
  echo "已取消"
  exit 1
fi

echo
echo "开始重装，请耐心等待..."
echo "----------------------------------------"

# 自动跳过用户名提示（直接回车使用 root）
printf "\n" | bash <(curl -sL https://raw.githubusercontent.com/bin456789/reinstall/main/reinstall.sh) \
  dd \
  --img="$IMAGE_URL" \
  --password="$PASSWORD"

echo
echo "----------------------------------------"
echo "准备完成，5 秒后自动重启..."
echo "请稍后重新连接（密码：$PASSWORD）"
sleep 5
reboot
