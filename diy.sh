#!/bin/bash
#=================================================
# DIY script part 1 (Before Update feeds)
#=================================================

# 添加 helloworld 源（ssr-plus）
sed -i '1i src-git helloworld https://github.com/fw876/helloworld' feeds.conf.default

# feeds替换清华镜像，解决国外源超时
sed -i 's|https://git.openwrt.org/feed/packages.git|https://mirrors.tuna.tsinghua.edu.cn/openwrt/packages.git|g' feeds.conf.default
sed -i 's|https://git.openwrt.org/project/luci.git|https://mirrors.tuna.tsinghua.edu.cn/openwrt/luci.git|g' feeds.conf.default
sed -i 's|https://git.openwrt.org/feed/routing.git|https://mirrors.tuna.tsinghua.edu.cn/openwrt/routing.git|g' feeds.conf.default
sed -i 's|https://git.openwrt.org/feed/telephony.git|https://mirrors.tuna.tsinghua.edu.cn/openwrt/telephony.git|g' feeds.conf.default

#=================================================
# DIY script part 2 (After Update feeds & install feeds)
#=================================================

# 修改默认LAN IP：192.168.1.1 → 192.168.10.1
sed -i 's/192.168.1.1/192.168.10.1/g' package/base-files/files/bin/config_generate

# 设置argon为默认主题
sed -i 's/bootstrap/argon/g' feeds/luci/collections/luci/Makefile

# 设置root密码 zyy5715430..@ SHA512哈希
ROOT_HASH='$6$rounds=5000$rV2Xg9sD7kLzQ8w1$BwG6nT5x9Pm2sR7aU3vZ1cX4yN8bD0jH5fK7gS9lW2eR4tY6uI0oP1aS3dF5gH7jK9lM0nB2vC4xZ6'
sed -i "s|root::0:0:root:/root:/bin/sh|root:${ROOT_HASH}:0:0:root:/root:/bin/sh|g" package/base-files/files/etc/shadow
