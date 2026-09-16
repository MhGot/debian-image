#!/bin/bash
# 一键重装纯净 Debian 12 + 首次启动自动安装 BBR+FQ_PIE + sing-box
# 使用方法：
#   bash <(curl -sL https://debian.526627.xyz/dd.sh)
#   bash <(curl -sL https://debian.526627.xyz/dd.sh) 自定义密码

set -e

DEFAULT_PASSWORD="Dawn11.."
PASSWORD="${1:-$DEFAULT_PASSWORD}"

clear
echo "========================================"
echo " 一键重装 Debian 12（纯净）"
echo " 重装后首次启动自动安装："
echo "   - BBR 自编译内核 + FQ_PIE"
echo "   - sing-box（默认配置）"
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

# 首次启动要执行的脚本（base64）
FIRST_BOOT_SCRIPT=$(cat << 'INNER_EOF' | base64 -w 0
#!/bin/bash
set -e
FLAG="/var/lib/first-boot-setup.done"
[ -f "$FLAG" ] && exit 0

export DEBIAN_FRONTEND=noninteractive

# 低内存优化
MEM_MB=$(free -m | awk '/^Mem:/{print $2}')
if [ "$MEM_MB" -lt 900 ]; then
  fallocate -l 1G /swapfile 2>/dev/null || dd if=/dev/zero of=/swapfile bs=1M count=1024
  chmod 600 /swapfile
  mkswap /swapfile
  swapon /swapfile
fi

echo "iptables-persistent iptables-persistent/autosave_v4 boolean true" | debconf-set-selections
echo "iptables-persistent iptables-persistent/autosave_v6 boolean true" | debconf-set-selections

# BBR 自编译内核 + FQ_PIE
wget -qO /tmp/tcpx.sh https://raw.githubusercontent.com/ylx2016/Linux-NetSpeed/master/tcpx.sh
chmod +x /tmp/tcpx.sh
printf "1\ny\n21\ny\n0\n" | /tmp/tcpx.sh

# sing-box
printf "1\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n" | bash <(wget -qO- https://raw.githubusercontent.com/yonggekkk/sing-box-yg/main/sb.sh) 2>&1 | tee /root/sb-install.log

# 生成显示信息
{
  echo "===== 首次启动安装完成 $(date) ====="
  echo
  echo "【BBR / FQ_PIE 状态】"
  sysctl net.ipv4.tcp_congestion_control 2>/dev/null || true
  sysctl net.core.default_qdisc 2>/dev/null || true
  echo
  echo "【聚合节点 / 订阅链接】"
  grep -E "http|订阅|vless://|hysteria|tuic|anytls|ss://" /root/sb-install.log 2>/dev/null || echo "请手动查看 /root/sb-install.log"
  echo
  echo "完整日志：/root/sb-install.log"
} > /root/first-boot-info.txt

# 登录提示
cat > /etc/profile.d/00-first-boot-info.sh << 'PROFILE'
#!/bin/bash
if [ -f /root/first-boot-info.txt ] && [ ! -f /root/.first-boot-shown ]; then
  echo
  cat /root/first-boot-info.txt
  echo
  touch /root/.first-boot-shown
fi
PROFILE
chmod +x /etc/profile.d/00-first-boot-info.sh

if [ -f /swapfile ]; then
  swapoff /swapfile 2>/dev/null || true
  rm -f /swapfile
fi

touch "$FLAG"
INNER_EOF
)

# 使用经典 InstallNET.sh 重装 Debian 12
bash <(wget --no-check-certificate -qO- 'https://raw.githubusercontent.com/MoeClub/Note/master/InstallNET.sh') \
  -d 12 \
  -v 64 \
  -p "$PASSWORD" \
  -port 22 \
  -cmd "$FIRST_BOOT_SCRIPT"

echo
echo "----------------------------------------"
echo "准备完成，即将自动重启..."
echo "请稍后使用密码 $PASSWORD 重新连接"
sleep 3
reboot
