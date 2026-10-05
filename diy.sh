#!/bin/bash
set -e

# 1. 拉取Lean OpenWrt源码
git clone https://github.com/coolsnowwolf/lede openwrt
cd openwrt

# 2. 修改默认IP 192.168.10.1
sed -i 's/192.168.1.1/192.168.10.1/g' package/base-files/files/bin/config_generate

# 3. 设置ROOT密码 zyy5715430..@
sed -i 's/root::0:0:root:\/root:\/bin\/ash/root:$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.:0:0:root:\/root:\/bin\/ash/g' package/base-files/files/etc/shadow

# 4. 添加插件源
# Argon主题
git clone https://github.com/jerrykuku/luci-theme-argon package/luci-theme-argon
# SSR-PLUS
git clone https://github.com/fw876/helloworld package/helloworld

# 5. 更新feeds
./scripts/feeds update -a
./scripts/feeds install -a

# 6. 生成精简 .config x86_64 N5105 I226(igc网卡驱动)
cat > .config <<EOF
CONFIG_TARGET_x86=y
CONFIG_TARGET_x86_64=y
CONFIG_TARGET_x86_64_DEVICE_generic=y
CONFIG_BUSYBOX_CUSTOM=y
CONFIG_BUSYBOX_CONFIG_FEATURE_EDITING=y
CONFIG_BUSYBOX_CONFIG_FEATURE_EDITING_SAVEHISTORY=y
CONFIG_KMOD_NETWORK_SUPPORT=y
CONFIG_PACKAGE_kmod-igc=y
CONFIG_PACKAGE_luci=y
CONFIG_PACKAGE_luci-theme-argon=y
CONFIG_PACKAGE_luci-app-ssr-plus=y
CONFIG_PACKAGE_curl=y
CONFIG_PACKAGE_wget=y
CONFIG_PACKAGE_openssl-util=y
CONFIG_PACKAGE_iptables-nft=y
EOF

# 7. 自动扩展.config依赖
make defconfig




