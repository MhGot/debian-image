cat > /root/dd.sh << 'EOF'
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
read -p "确认继续？请输入 yes 继续: " confirm
[[ "$confirm" != "yes" ]] && echo "已取消" && exit 1

echo
echo "开始重装，请耐心等待..."

bash <(curl -sL https://raw.githubusercontent.com/bin456789/reinstall/main/reinstall.sh) \
  --image "$IMAGE_URL" \
  --password "$PASSWORD"
EOF

chmod +x /root/dd.sh