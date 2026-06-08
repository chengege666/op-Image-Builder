#!/bin/bash
# scripts/set_pppoe.sh
# Usage: ENABLE_PPPOE=true PPPOE_USER=user PPPOE_PASS=pass ./scripts/set_pppoe.sh

if [ "${ENABLE_PPPOE}" != "true" ]; then
    echo "PPPoE configuration disabled, skipping..."
    exit 0
fi

if [ -z "${PPPOE_USER}" ] || [ -z "${PPPOE_PASS}" ]; then
    echo "PPPoE credentials missing, skipping..."
    exit 0
fi

echo "Setting PPPoE configuration..."
# Use the 'files' folder in build root to inject custom files
mkdir -p files/etc/uci-defaults
cat > files/etc/uci-defaults/99-pppoe <<EOF
uci set network.wan.proto='pppoe'
uci set network.wan.username='${PPPOE_USER}'
uci set network.wan.password='${PPPOE_PASS}'
uci commit network
EOF
chmod +x files/etc/uci-defaults/99-pppoe
