#!/bin/bash
# scripts/add_docker.sh
# Usage: ENABLE_DOCKER=true ./scripts/add_docker.sh

if [ "${ENABLE_DOCKER}" != "true" ]; then
    exit 0
fi

# For Image Builder, we just need to list packages
# 添加 docker-compose 和依赖库 luci-lib-docker 以确保功能完整
echo "dockerd docker docker-compose luci-app-dockerman luci-lib-docker cgroupfs-mount luci-i18n-dockerman-zh-cn" >> custom_packages.txt

# 确保 dockerd 服务开机自启
# 如果服务不启动，LuCI 界面无法连接 Docker 守护进程，会导致只显示"配置"菜单
mkdir -p files/etc/uci-defaults
cat <<EOF > files/etc/uci-defaults/99-docker-enable
#!/bin/sh
uci set dockerd.globals.auto_start='1'
uci commit dockerd
/etc/init.d/dockerd enable
/etc/init.d/dockerd start
exit 0
EOF
chmod +x files/etc/uci-defaults/99-docker-enable
