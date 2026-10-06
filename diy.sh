#!/bin/bash
set -e
# ImmortalWrt openwrt-23.05 原生5.15内核，增加镜像重试防128错误
if [ ! -d openwrt ];then
  echo "拉取 ImmortalWrt openwrt-23.05"
  git clone --depth=1 -b openwrt-23.05 https://github.com/immortalwrt/immortalwrt openwrt || \
  git clone --depth=1 -b openwrt-23.05 https://mirror.ghproxy.com/https://github.com/immortalwrt/immortalwrt openwrt
fi
cd openwrt

# 修改LAN管理地址 192.168.10.1
sed -i 's/192.168.1.1/192.168.10.1/g' package/base-files/files/bin/config_generate

# 设置root密码 zyy5715430..@
sed -i 's/root:::0:0:root:\/root:\/bin\/ash/root:$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.:0:0:root:\/root:\/bin\/ash/g' package/base-files/files/etc/shadow

# 清理旧插件目录，避免多次编译残留冲突
rm -rf package/luci-theme-argon package/helloworld

# Git超时优化，防止长时间拉取断开
git config --global http.lowSpeedLimit 0
git config --global http.lowSpeedTime 999999

# 拉取 Argon主题，多源兜底
echo "====拉取Argon主题===="
git clone --depth=1 https://github.com/jerrykuku/luci-theme-argon package/luci-theme-argon || \
git clone --depth=1 https://mirror.ghproxy.com/https://github.com/jerrykuku/luci-theme-argon package/luci-theme-argon

# 拉取 helloworld(ssr-plus)，多源兜底
echo "====拉取SSR-Plus helloworld===="
git clone --depth=1 https://github.com/fw876/helloworld package/helloworld || \
git clone --depth=1 https://mirror.ghproxy.com/https://github.com/fw876/helloworld package/helloworld

# 更新feeds
./scripts/feeds update -a || ./scripts/feeds update -a
./scripts/feeds install -a

# 精简 .config 配置：x86_64 + I226 igc驱动 + luci + argon + ssr-plus
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







