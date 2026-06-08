#!/bin/bash
# scripts/add_store.sh
# Usage: ENABLE_STORE=true ./scripts/add_store.sh

if [ "${ENABLE_STORE}" != "true" ]; then
    exit 0
fi

# For Image Builder:
# 1. Add repository to repositories.conf
# 2. Add package to custom_packages.txt

# Use iStore linkease repo
echo "src/gz istore https://istore.linkease.com/repo/all/store" >> repositories.conf

# Add public key
# We will download the key in the workflow to avoid complexity here, or wget it
wget -qO - https://istore.linkease.com/repo/all/store/istore.pub >> keys/istore.pub

# Add the main store package
echo "luci-app-store" >> custom_packages.txt
