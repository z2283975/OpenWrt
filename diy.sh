#!/bin/bash
#=================================================
# DIY script part1：feeds更新前，只配置源
#=================================================

# 判断helloworld源不存在才追加，防止重复
if ! grep -q "src-git helloworld" feeds.conf.default;then
  echo "src-git helloworld https://gitee.com/fw876/helloworld.git" >> feeds.conf.default
fi

# feeds替换清华镜像
sed -i 's|https://git.openwrt.org/feed/packages.git|https://mirrors.tuna.tsinghua.edu.cn/openwrt/packages.git|g' feeds.conf.default
sed -i 's|https://git.openwrt.org/project/luci.git|https://mirrors.tuna.tsinghua.edu.cn/openwrt/luci.git|g' feeds.conf.default
sed -i 's|https://git.openwrt.org/feed/routing.git|https://mirrors.tuna.tsinghua.edu.cn/openwrt/routing.git|g' feeds.conf.default
sed -i 's|https://git.openwrt.org/feed/telephony.git|https://mirrors.tuna.tsinghua.edu.cn/openwrt/telephony.git|g' feeds.conf.default

#=================================================
# DIY script part2：执行feeds更新安装，生成feeds目录
#=================================================
./scripts/feeds update -a
./scripts/feeds install -a

# 修改默认LAN IP：192.168.1.1 → 192.168.10.1
sed -i 's/192.168.1.1/192.168.10.1/g' package/base-files/files/bin/config_generate

# 【方案：首次开机自动设置Argon主题，不再修改feeds下Makefile，规避文件不存在报错】
mkdir -p package/base-files/files/etc/uci-defaults
cat > package/base-files/files/etc/uci-defaults/99-set-argon << EOF
uci set luci.main.mediaurlbase=/luci-static/argon
uci commit luci
EOF

# 设置root密码 zyy5715430..@
ROOT_HASH='$6$rounds=5000$rV2Xg9sD7kLzQ8w1$BwG6nT5x9Pm2sR7aU3vZ1cX4yN8bD0jH5fK7gS9lW2eR4tY6uI0oP1aS3dF5gH7jK9lM0nB2vC4xZ6'
sed -i "s|root::0:0:root:/root:/bin/sh|root:${ROOT_HASH}:0:0:root:/root:/bin/sh|g" package/base-files/files/etc/shadow


