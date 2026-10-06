#!/bin/bash
set -e
# 克隆Lean Lede，切换到原生5.15内核历史快照
if [ ! -d openwrt ];then
  echo "克隆Lean Lede源码"
  git clone https://github.com/coolsnowwolf/lede openwrt || \
  git clone https://mirror.ghproxy.com/https://github.com/coolsnowwolf/lede openwrt
fi
cd openwrt
# 切换到5.15内核快照提交
git checkout f221abf682d721f60e228f67eb4c94c32b5dd72c

# 修改LAN管理地址 192.168.10.1
sed -i 's/192.168.1.1/192.168.10.1/g' package/base-files/files/bin/config_generate

# 设置root密码 zyy5715430..@
sed -i 's/root:::0:0:root:\/root:\/bin\/ash/root:$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.:0:0:root:\/root:\/bin\/ash/g' package/base-files/files/etc/shadow

# 清理旧插件目录，防止多次编译残留冲突
rm -rf package/luci-theme-argon package/helloworld

# Git超时优化，防止长时间拉取断开
git config --global http.lowSpeedLimit 0
git config --global http.lowSpeedTime 999999

# Argon主题 多源兜底
echo "====拉取Argon主题===="
git clone --depth=1 https://github.com/jerrykuku/luci-theme-argon package/luci-theme-argon || \
git clone --depth=1 https://mirror.ghproxy.com/https://github.com/jerrykuku/luci-theme-argon package/luci-theme-argon

# SSR-Plus helloworld 多源兜底
echo "====拉取SSR-Plus helloworld===="
git clone --depth=1 https://github.com/fw876/helloworld package/helloworld || \
git clone --depth=1 https://mirror.ghproxy.com/https://github.com/fw876/helloworld package/helloworld

# 自动写入I226网卡PCI省电关闭，防止高负载断流
echo "echo pcie_aspm=off >> /etc/bootcmd.d/01_disable_aspm" >> package/base-files/files/etc/rc.local


# 更新feeds
./scripts/feeds update -a || ./scripts/feeds update -a
./scripts/feeds install -a

# 精简.config x86_64 N5105 I226 igc网卡驱动
cat > .config <<EOF
CONFIG_TARGET_x86=y
CONFIG_TARGET_x86_64=y
CONFIG_TARGET_x86_64_DEVICE_generic=y
CONFIG_PACKAGE_kmod-igc=y
CONFIG_PACKAGE_luci=y
CONFIG_PACKAGE_luci-theme-argon=y
CONFIG_PACKAGE_luci-app-ssr-plus=y
CONFIG_PACKAGE_curl=y
CONFIG_PACKAGE_wget=y
CONFIG_PACKAGE_openssl-util=y
CONFIG_PACKAGE_iptables-nft=y
CONFIG_LIBCURL_OPENSSL=y
EOF

make defconfig
make clean








