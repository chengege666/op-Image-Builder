#!/bin/bash

# 1. 添加软件源 (保证能找到插件)
echo 'src-git kiddin9 https://github.com/kiddin9/openwrt-packages' >> feeds.conf.default
./scripts/feeds update -a && ./scripts/feeds install -a

# 2. 读取 apps.list 并修改 .config
LIST_FILE="scripts/apps.list"
if [ -f "$LIST_FILE" ]; then
    while IFS= read -r line || [ -n "$line" ]; do
        [ -z "$line" ] && continue
        if [[ "$line" != \#* ]]; then
            PKG=$(echo "$line" | xargs)
            sed -i "/CONFIG_PACKAGE_$PKG=y/d" .config
            echo "CONFIG_PACKAGE_$PKG=y" >> .config
            echo "已启用插件: $PKG"
        else
            PKG=$(echo "$line" | sed 's/^#//' | xargs)
            sed -i "/CONFIG_PACKAGE_$PKG=y/d" .config
            echo "# CONFIG_PACKAGE_$PKG is not set" >> .config
            echo "已禁用插件: $PKG"
        fi
    done < "$LIST_FILE"
fi
