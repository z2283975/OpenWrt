#!/bin/bash
# ============================================================
# OpenWrt 自定义脚本：N5105 + I226 + 5.15 + SSR-plus + Argon
# 管理地址：192.168.10.1
# ============================================================

set -e

# 1. 修改默认 LAN 管理地址为 192.168.10.1
if [ -f package/base-files/files/bin/config_generate ]; then
    sed -i "s/192\.168\.[0-9]*\.[0-9]*/192.168.10.1/g" package/base-files/files/bin/config_generate
fi

# 兼容旧版源码路径
if [ -f package/base-files/files/lib/functions/uci-defaults.sh ]; then
    sed -i "s/192\.168\.[0-9]*\.[0-9]*/192.168.10.1/g" package/base-files/files/lib/functions/uci-defaults.sh
fi

# 2. 设置默认主题为 Argon
if grep -q "luci-theme-argon" .config 2>/dev/null; then
    echo "CONFIG_PACKAGE_luci-theme-argon=y" >> .config 2>/dev/null || true
    sed -i 's/CONFIG_PACKAGE_luci-theme-bootstrap=y/CONFIG_PACKAGE_luci-theme-bootstrap=n/' .config 2>/dev/null || true

    # 在 uci-defaults 中写入默认主题，刷入后自动生效
    mkdir -p package/base-files/files/etc/uci-defaults
    cat > package/base-files/files/etc/uci-defaults/99-default-theme <<'EOF'
#!/bin/sh
uci set luci.main.mediaurlbase='/luci-static/argon'
uci commit luci
exit 0
EOF
    chmod +x package/base-files/files/etc/uci-defaults/99-default-theme
fi

# 3. 清理临时文件，避免旧缓存影响编译
rm -rf tmp/

















