#!/bin/bash
set -e
# 克隆Lean Lede 23.05分支，原生5.15内核
if [ ! -d openwrt ];then
git clone --depth=1 -b 23.05 https://github.com/coolsnowwolf/lede openwrt
fi
cd openwrt

# 修改默认网关IP：192.168.10.1
sed -i 's/192.168.1.1/192.168.10.1/g' package/base-files/files/bin/config_generate
# 设置root密码 zyy5715430..@
sed -i 's/root:::0:0:root:\/root:\/bin\/ash/root:$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.:0:0:root:\/root:\/bin\/ash/g' package/base-files/files/etc/shadow
# 清理旧插件目录，防止多次编译残留冲突
rm -rf package/luci-theme-argon package/helloworld
# 增加git超时配置，防止长时间连接断开
git config --global http.lowSpeedLimit 0
git config --global http.lowSpeedTime 999999
# Argon主题 多镜像轮换
echo "====拉取Argon主题===="
git clone --depth=1 https://github.com/jerrykuku/luci-theme-argon package/luci-theme-argon || \
git clone --depth=1 shturl.cc/pd56q8RGr0wzoTbjpSeh2TWwph5hTrNQ6j61uxl2l3eZKCVsQNieo2 package/luci-theme-argon || \
git clone --depth=1 https://mirror.ghproxy.com/https://github.com/jerrykuku/luci-theme-argon package/luci-theme-argon
# SSR-Plus helloworld 多镜像轮换，重点修复429限流
echo "====拉取SSR-Plus(helloworld)===="
git clone --depth=1 https://github.com/fw876/helloworld package/helloworld || \
git clone --depth=1 shturl.cc/fhlgvUr824zWY6HuzgXQ1UiTjdzFCYNpKZJVfLSJqGLR package/helloworld || \
git clone --depth=1 https://mirror.ghproxy.com/https://github.com/fw876/helloworld package/helloworld
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





