# OpenWrt x86_64 自动构建

基于 GitHub Actions + Image Builder，快速生成定制化 OpenWrt/ImmortalWrt 固件。

## 支持设备

| 设备 | 固件 |
|------|------|
| x86_64 软路由 | OpenWrt / ImmortalWrt |
| P&W R619AC (竞斗云 2.0) | OpenWrt |

## 特性

- **极速构建**：Image Builder 方式，通常 5-20 分钟
- **多版本**：支持 OpenWrt 24.10.x / 25.12.x / SNAPSHOT
- **可选插件**：iStore 应用商店、Docker、PPPoE 拨号、Argon 主题、OpenClash
- **自动扩容**：x86_64 支持自定义系统分区大小 (1GB/2GB/4GB/自定义)
- **中文界面**：默认集成简体中文语言包
- **多构建类型**：squashfs/ext4 (物理机)、rootfs (容器)

## 快速使用

1. Fork 本仓库
2. 进入 **Actions** 页面，选择对应工作流
3. 点击 **Run workflow**，按需填写参数后开始构建
4. 构建完成后在 **Artifacts** 下载固件

### 参数说明

| 参数 | 默认值 |
|------|--------|
| 固件构建类型 | squashfs_ext4 |
| OpenWrt 版本 | 24.10.7 |
| 固件大小 | 1024 MB |
| LAN IP | 192.168.1.1 |
| iStore / Docker / PPPoE | 关闭 |

## 项目结构

```
.
├── .github/workflows/   # GitHub Actions 工作流
├── config/
│   └── base.config      # 基础配置
└── scripts/             # 构建脚本 (IP/分区/Docker/PPPoE)
```

## 默认凭证

- 管理地址：http://192.168.1.1
- 用户名：`root`
- 密码：无（首次登录需设置）

## 配合工具

- [PVE 镜像转换工具 (pvezh)](https://github.com/chengege666/pvezh) — 一键导入固件到 Proxmox VE
