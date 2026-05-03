#!/bin/bash
# scripts/download_third_party_ipk.sh
# 从 GitHub Releases 下载第三方 ipk 及其语言包

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/../config/third_party_ipk.conf"
DOWNLOAD_DIR="$(pwd)/packages/third_party"
CUSTOM_PACKAGES_FILE="$(pwd)/custom_packages.txt"

# 创建下载目录
mkdir -p "$DOWNLOAD_DIR"

# 检查配置文件
if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ 错误: 配置文件不存在: $CONFIG_FILE"
    exit 1
fi

# GitHub API 基础 URL
GITHUB_API="https://api.github.com"

# 下载函数：通过 GitHub API 获取最新 release 的 asset
download_from_github() {
    local repo="$1"
    local pattern="$2"
    local output_dir="$3"
    
    echo "📦 正在从 GitHub 下载: $repo (匹配: $pattern)"
    
    # 获取最新 release 信息
    local release_json
    release_json=$(curl -sL --retry 3 --retry-delay 5 \
        -H "Accept: application/vnd.github+json" \
        "$GITHUB_API/repos/$repo/releases/latest" 2>/dev/null || echo "")
    
    if [ -z "$release_json" ]; then
        echo "  ⚠️ 警告: 无法获取 $repo 的 release 信息"
        return 1
    fi
    
    # 检查是否有错误
    if echo "$release_json" | grep -q '"message"'; then
        local error_msg
        error_msg=$(echo "$release_json" | grep -o '"message": *"[^"]*"' | head -1)
        echo "  ⚠️ 警告: GitHub API 返回错误: $error_msg"
        return 1
    fi
    
    # 获取匹配 pattern 的 asset 下载 URL
    local download_url
    download_url=$(echo "$release_json" | grep -o '"browser_download_url": *"[^"]*"' | \
        grep "$pattern" | head -1 | cut -d'"' -f4)
    
    if [ -z "$download_url" ]; then
        echo "  ⚠️ 警告: 未找到匹配 '$pattern' 的 asset"
        return 1
    fi
    
    # 下载文件
    local filename
    filename=$(basename "$download_url")
    echo "  ⬇️  下载: $filename"
    
    if wget -q -O "$output_dir/$filename" "$download_url"; then
        echo "  ✅ 下载成功: $filename"
        return 0
    else
        echo "  ❌ 下载失败: $filename"
        rm -f "$output_dir/$filename"
        return 1
    fi
}

# 查找并下载语言包
download_lang_pack() {
    local main_package="$1"
    local output_dir="$2"
    
    # 从主包名生成语言包名
    # 例如: luci-theme-argon -> luci-i18n-argon-zh-cn
    #      luci-app-argon-config -> luci-i18n-argon-config-zh-cn
    local lang_pattern
    if echo "$main_package" | grep -q "luci-app-"; then
        # luci-app-xxx-yyy -> luci-i18n-xxx-yyy-zh-cn
        local app_name="${main_package#luci-app-}"
        lang_pattern="luci-i18n-${app_name}-zh-cn"
    elif echo "$main_package" | grep -q "luci-theme-"; then
        # luci-theme-xxx -> luci-i18n-theme-xxx-zh-cn
        local theme_name="${main_package#luci-theme-}"
        lang_pattern="luci-i18n-theme-${theme_name}-zh-cn"
    else
        # 通用规则: xxx -> luci-i18n-xxx-zh-cn
        lang_pattern="luci-i18n-${main_package}-zh-cn"
    fi
    
    echo "  🔍 查找语言包: $lang_pattern"
    
    # 尝试从 OpenWrt 官方源下载
    local version="${VERSION:-24.10.6}"
    local base_url
    
    if [ "$version" = "SNAPSHOT" ]; then
        base_url="https://downloads.openwrt.org/snapshots/packages/x86_64/luci"
    else
        base_url="https://downloads.openwrt.org/releases/$version/packages/x86_64/luci"
    fi
    
    # 下载 Packages.gz 并查找语言包
    local packages_gz="$output_dir/Packages.gz"
    if wget -q -O "$packages_gz" "$base_url/Packages.gz" 2>/dev/null; then
        local lang_ipk
        lang_ipk=$(zgrep -o "Filename:.*${lang_pattern}.*ipk" "$packages_gz" | head -1 | cut -d' ' -f2)
        
        if [ -n "$lang_ipk" ]; then
            echo "  ⬇️  下载语言包: $lang_ipk"
            if wget -q -O "$output_dir/$(basename "$lang_ipk")" "$base_url/$lang_ipk"; then
                echo "  ✅ 语言包下载成功"
                echo "$main_package" >> "$CUSTOM_PACKAGES_FILE"
                rm -f "$packages_gz"
                return 0
            fi
        fi
    fi
    
    rm -f "$packages_gz"
    echo "  ⚠️ 未找到或下载失败: $lang_pattern"
    return 1
}

# 主处理逻辑
echo "========================================="
echo "🚀 开始下载第三方 ipk 包"
echo "========================================="

success_count=0
fail_count=0

while IFS= read -r line; do
    # 跳过注释和空行
    [[ "$line" =~ ^#.*$ ]] && continue
    [[ -z "$line" ]] && continue
    
    # 解析配置行
    IFS='|' read -r repo pattern package_name need_lang <<< "$line"
    
    # 去除空格
    repo=$(echo "$repo" | xargs)
    pattern=$(echo "$pattern" | xargs)
    package_name=$(echo "$package_name" | xargs)
    need_lang=$(echo "$need_lang" | xargs)
    
    echo ""
    echo "📌 处理: $package_name"
    
    # 下载主程序
    if download_from_github "$repo" "$pattern" "$DOWNLOAD_DIR"; then
        # 添加到自定义包列表
        echo "$package_name" >> "$CUSTOM_PACKAGES_FILE"
        success_count=$((success_count + 1))
        
        # 下载语言包
        if [ "$need_lang" = "true" ]; then
            download_lang_pack "$package_name" "$DOWNLOAD_DIR" || true
        fi
    else
        fail_count=$((fail_count + 1))
        echo "  ⚠️ 跳过: $package_name"
    fi
    
done < "$CONFIG_FILE"

echo ""
echo "========================================="
echo "✅ 下载完成"
echo "   成功: $success_count"
echo "   失败: $fail_count"
echo "========================================="

# 显示下载的文件
if [ -d "$DOWNLOAD_DIR" ] && [ "$(ls -A $DOWNLOAD_DIR/*.ipk 2>/dev/null)" ]; then
    echo ""
    echo "📁 已下载的 ipk 文件:"
    ls -lh "$DOWNLOAD_DIR"/*.ipk 2>/dev/null | awk '{print "   " $NF " (" $5 ")"}'
fi

exit 0
