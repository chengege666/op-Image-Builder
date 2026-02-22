# OpenWrt x86_64 自动构建项目 (Image Builder 版)  自己用的扩容固件

这是一个基于 GitHub Actions 的 OpenWrt x86_64 固件自动构建项目。本项目采用 **Image Builder (镜像生成器)** 技术，而非传统的源码编译，能够在几分钟内快速生成定制化的 OpenWrt 固件。

## ✨ 主要特性

*   **极速构建**: 使用官方 Image Builder，构建时间通常在 5-20 分钟内。
*   **高度可定制**: 支持在构建前配置固件大小、LAN IP、OpenWrt 版本等。
*   **常用插件集成**:
    *   **iStore 应用商店**: 方便新手安装和管理插件（已解决密钥验证问题）。
    *   **Docker**: 容器化应用支持。
    *   **PPPoE**: 支持预设拨号账号密码。
*   **中文界面**: 默认集成简体中文语言包 (LuCI, Firewall)。
*   **自动扩容**: 支持自定义系统分区大小 (1GB/2GB/4GB)，避免空间不足。

## 🚀 如何使用

1.  进入本仓库的 **[Actions](https://github.com/your-username/your-repo/actions)** 页面。
2.  在左侧选择 **"构建 OpenWrt x86_64 (Image Builder)"** 工作流。
3.  点击右侧的 **"Run workflow"** 按钮。
4.  根据需求填写/选择参数：
    *   **固件大小 (MB)**: 默认 `1024` (1GB)，建议安装 Docker/iStore 时选择更大。
    *   **路由器管理地址 (LAN IP)**: 默认 `192.168.1.1`，可自定义。
    *   **OpenWrt 版本**: 支持 `24.10.x` (最新稳定版)、`23.05.x` 或 `SNAPSHOT`。
    *   **启用应用商店 (iStore)**: 勾选以集成 iStore。
    *   **启用 Docker**: 勾选以集成 Docker 环境。
    *   **启用 PPPoE**: 勾选以预设拨号信息（需填写下方用户名和密码）。
5.  点击绿色的 **"Run workflow"** 开始构建。

## 📦 构建产物

构建完成后，在 Workflow 运行记录页面的 **Artifacts** 区域可以下载生成的固件包：

*   **文件名格式**: `OpenWrt_Firmware_[版本]_[大小]MB.zip`
*   **包含文件**: 解压后通常包含 `.img.gz` (gzip 压缩镜像) 和 `.img` (原始镜像)。
*   **使用方法**: 解压后使用写盘工具 (如 Rufus, BalenaEtcher) 写入软路由硬盘或虚拟机虚拟磁盘即可。

## 🛠️ 项目结构

*   `.github/workflows/build.yml`: GitHub Actions 核心工作流配置文件。
*   `config/base.config`: 基础配置文件 (目前主要由 Image Builder 默认配置接管)。
*   `scripts/`: 自定义脚本目录。
    *   `set_ip.sh`: 设置 LAN IP。
    *   `set_partition.sh`: 调整分区大小。
    *   `add_docker.sh`: 添加 Docker 相关包。
    *   `set_pppoe.sh`: 配置 PPPoE 拨号。

## ⚠️ 注意事项

*   **iStore 集成**: 由于 iStore 官方源密钥验证问题，目前采用离线包下载方式集成，构建时会自动处理。
*   **版本兼容性**: 推荐使用 `24.10.x` 或 `23.05.x` 稳定版。SNAPSHOT 版本可能不够稳定。
*   **opkg 中文**: 部分新版 OpenWrt 可能已移除独立的 opkg 中文包，本项目已做适配处理。
