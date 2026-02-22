#!/bin/bash
# scripts/set_partition.sh
# Usage: FIRMWARE_SIZE=1024 ./scripts/set_partition.sh

if [ -z "${FIRMWARE_SIZE}" ]; then
    exit 0
fi

# 检查 .config 是否存在
[ -f .config ] || touch .config

# 如果存在配置项，则替换
if grep -q "CONFIG_TARGET_ROOTFS_PARTSIZE" .config; then
    sed -i "s/CONFIG_TARGET_ROOTFS_PARTSIZE=[0-9]*/CONFIG_TARGET_ROOTFS_PARTSIZE=${FIRMWARE_SIZE}/" .config
else
    # 如果不存在，则追加
    echo "CONFIG_TARGET_ROOTFS_PARTSIZE=${FIRMWARE_SIZE}" >> .config
fi

echo "Set firmware size to ${FIRMWARE_SIZE}MB"
