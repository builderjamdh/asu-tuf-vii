# ASUS TUF-BE3600 V2 魔改固件 编译指引

## 1. 编译环境准备

### 1.1 操作系统要求

推荐 Ubuntu 20.04 LTS (64-bit)。其他支持的系统：

| 系统 | 备注 |
|------|------|
| Ubuntu 20.04 LTS | 推荐 |
| Ubuntu 22.04 LTS | 需额外安装 libcrypt-dev |
| Debian 11 | 可用，部分包名不同 |
| Fedora 35+ | 需 dnf 等效包 |

**WSL2 (Windows Subsystem for Linux) 也可使用**，但需确保：
- 使用 WSL2 非 WSL1
- 磁盘空间充足 (编译完整固件需要约 30GB+)
- 内存不低于 8GB (建议 16GB)

### 1.2 安装依赖包

```bash
# Ubuntu 20.04/22.04
sudo apt update
sudo apt install -y \
    build-essential \
    gcc \
    g++ \
    flex \
    bison \
    patch \
    gettext \
    unzip \
    libncurses5-dev \
    libncursesw5-dev \
    libssl-dev \
    libelf-dev \
    zlib1g-dev \
    gawk \
    wget \
    git \
    diffstat \
    subversion \
    chrpath \
    texinfo \
    help2man \
    cpio \
    python3 \
    python3-dev \
    python3-distutils \
    libc6-i386 \
    lib32stdc++6 \
    lib32z1 \
    autoconf \
    automake \
    libtool \
    cmake \
    pkg-config \
    libglib2.0-dev \
    intltool \
    xsltproc \
    libxml2-dev \
    libsqlite3-dev \
    uuid-dev \
    libgpg-error-dev \
    libgcrypt20-dev \
    libjson-c-dev \
    libcurl4-openssl-dev \
    libpcap-dev \
    libbz2-dev

# Ubuntu 22.04 额外需要
sudo apt install -y libcrypt-dev
```

### 1.3 安装交叉编译工具链

ASUS 官方 GPL 发布不含预编译工具链。需获取 HND ARM 工具链并放置到指定路径：

```bash
# HND ARM 平台 GCC 10.3 (核心必需)
# 目标路径: /opt/toolchains/crosstools-arm_softfp-gcc-10.3-linux-4.19-glibc-2.32-binutils-2.36.1/
# 来源: Broadcom HND SDK 或从 ASUS 支持渠道获取

# 验证工具链安装
ls /opt/toolchains/crosstools-arm_softfp-gcc-10.3-linux-4.19-glibc-2.32-binutils-2.36.1/usr/bin/arm-buildroot-linux-gnueabi-gcc

# 检查版本
/opt/toolchains/crosstools-arm_softfp-gcc-10.3-linux-4.19-glibc-2.32-binutils-2.36.1/usr/bin/arm-buildroot-linux-gnueabi-gcc --version
# 期望输出: arm-buildroot-linux-gnueabi-gcc (Buildroot ...) 10.3.0
```

### 1.4 设置环境变量

```bash
# 添加到 ~/.bashrc 或每次编译前执行
export PATH="/opt/toolchains/crosstools-arm_softfp-gcc-10.3-linux-4.19-glibc-2.32-binutils-2.36.1/usr/bin:$PATH"
export CROSS_COMPILE="arm-buildroot-linux-gnueabi-"
export ARCH="arm"

# 设置工具链前缀
export TOOLCHAIN_BASE="/opt/toolchains/crosstools-arm_softfp-gcc-10.3-linux-4.19-glibc-2.32-binutils-2.36.1"
```

## 2. 编译固件

### 2.1 完整编译

```bash
# 进入 HND SDK 目录
cd release/src-rt-5.04behnd.4916

# 编译 TUF-BE3600 V2 固件
make TUF-BE3600_V2
```

首次编译可能需要 2-4 小时（取决于机器性能）。后续增量编译 10-30 分钟。

### 2.2 仅编译特定组件

```bash
# 仅编译内核
cd release/src-rt-5.04behnd.4916
make TUF-BE3600_V2 kernel

# 仅编译用户态 (router)
make TUF-BE3600_V2 router

# 仅编译 RC 服务
cd release/src/router/rc
make -f Makefile TUF-BE3600_V2
```

### 2.3 清理构建

```bash
# 完全清理
cd release/src-rt-5.04behnd.4916
make TUF-BE3600_V2 clean

# 仅清理 kernel
make TUF-BE3600_V2 kernel_clean
```

## 3. 固件产物

编译成功后，固件文件通常位于：

```
release/src-rt-5.04behnd.4916/image/
├── TUF-BE3600_V2_xxx.trx          # 主固件 (通过 Web UI 刷入)
└── TUF-BE3600_V2_xxx_cferom.bin   # 含 CFE 的完整映像 (救援模式用)
```

## 4. 构建系统关键文件

| 文件 | 作用 |
|------|------|
| `release/src-rt-5.04behnd.4916/Makefile` | 主构建入口 |
| `release/src-rt-5.04behnd.4916/target.mak` (顶层 src-rt/) | 目标机型 TUF-BE3600_V2 定义 |
| `release/src-rt-5.04behnd.4916/chip_profile.mak` | BCM6764 芯片配置 |
| `release/src-rt-5.04behnd.4916/targets/96764GW/96764GW.TUF-BE3600_V2` | 内核配置 + 构建选项 |
| `release/src-rt-5.04behnd.4916/kernel/linux-4.19/config_base.6a.6764` | 内核基础 .config |
| `release/src-rt-5.04behnd.4916/targets/nvram/6764/TUF-BE3600_V2.nvm` | NVRAM 默认值 |
| `release/src-rt-5.04behnd.4916/kernel/dts/6764/6764.dtsi` | 芯片级设备树 |
| `release/src/router/rc/init.c` | 模型初始化 + rc_support |

## 5. 刷入固件

1. 登录路由器 Web 管理界面 (通常 `192.168.50.1`)
2. 进入「系统管理」→「固件更新」
3. 上传编译好的 `.trx` 文件
4. 等待刷入完成并自动重启

**救援模式刷入**：按住 Reset 按钮通电，电源灯闪烁时通过 ASUS Firmware Restoration 工具上传固件。

## 6. 常见问题

### 编译错误: 找不到 arm-buildroot-linux-gnueabi-gcc
→ 工具链未安装或 PATH 未设置。检查 `/opt/toolchains/` 目录。

### 编译错误: 某些 .o 文件缺失
→ ASUS GPL 发布中部分闭源组件是预编译 .o 文件。检查 `release/src/router/*/prebuild/` 目录是否存在。

### 编译成功但固件无法启动
→ 检查 CFE/NVRAM 兼容性。可通过串口 TTL 查看启动日志。

### WSL2 编译慢
→ 确保源码放在 WSL2 原生 ext4 文件系统中（非 /mnt/c/），否则 I/O 性能极差。

---

## 7. GitHub Actions 编译工作流

### 7.1 架构选择

ASUSWRT HND 固件编译需要 **30GB+ 磁盘空间** 和 **8GB+ 内存**，且依赖 Broadcom 闭源交叉编译工具链（无法通过 apt 安装）。因此有两种 CI 方案：

| 方案 | 优点 | 缺点 |
|------|------|------|
| **A: Self-Hosted Runner（推荐）** | 性能好、可复用工具链缓存、编译快 | 需要一台常开 Linux 机器 |
| **B: GitHub-Hosted Runner + 工具链缓存** | 无需自备机器、免费额度内可用 | 首次编译慢（需下载工具链）、磁盘空间受限 |

**推荐方案 A**：在本地 WSL2 Ubuntu 或独立 Linux 服务器上部署 Self-Hosted Runner。

### 7.2 方案 A: Self-Hosted Runner

#### 7.2.1 准备 Runner 机器

```bash
# 在 Ubuntu 20.04/22.04 机器上
sudo useradd -m -s /bin/bash builder
sudo usermod -aG sudo builder
sudo su - builder

# 安装依赖
sudo apt update && sudo apt install -y build-essential flex bison patch gettext unzip \
    libncurses5-dev libncursesw5-dev libssl-dev libelf-dev zlib1g-dev gawk wget git \
    diffstat subversion chrpath texinfo help2man cpio python3 python3-dev cmake pkg-config

# 安装交叉编译工具链
# 将工具链放到 /opt/toolchains/crosstools-arm_softfp-gcc-10.3-linux-4.19-glibc-2.32-binutils-2.36.1/

# 安装 GitHub Actions Runner
mkdir -p ~/actions-runner && cd ~/actions-runner
curl -o actions-runner-linux-x64-2.319.1.tar.gz -L \
  https://github.com/actions/runner/releases/download/v2.319.1/actions-runner-linux-x64-2.319.1.tar.gz
tar xzf actions-runner-linux-x64-2.319.1.tar.gz

# 注册 Runner (替换 YOUR_TOKEN 为 GitHub Settings → Actions → Runners → New self-hosted runner 显示的 token)
./config.sh --url https://github.com/YOUR_USERNAME/asus-tuf-v2-dahi \
  --token YOUR_TOKEN --name asus-builder --labels asus-build --work _work

# 安装为系统服务
sudo ./svc.sh install builder
sudo ./svc.sh start
```

#### 7.2.2 工具链缓存

首次 Runner 注册后，将工具链放到固定路径并配置为只读，避免每次构建重复下载：

```bash
# 工具链路径（与 01_BUILD_GUIDE.md 1.3 节一致）
ls /opt/toolchains/crosstools-arm_softfp-gcc-10.3-linux-4.19-glibc-2.32-binutils-2.36.1/usr/bin/arm-buildroot-linux-gnueabi-gcc

# 验证
/opt/toolchains/crosstools-arm_softfp-gcc-10.3-linux-4.19-glibc-2.32-binutils-2.36.1/usr/bin/arm-buildroot-linux-gnueabi-gcc --version
```

### 7.3 方案 B: GitHub-Hosted Runner (ubuntu-latest)

若使用 GitHub 托管 Runner，需在 workflow 中安装工具链。工具链压缩包上传到 GitHub Releases 或 Self-Hosted Storage 后在 workflow 中下载。

### 7.4 Workflow 文件

在仓库根目录创建 `.github/workflows/build.yml`：

```yaml
name: Build TUF-BE3600 V2 Firmware

on:
  push:
    branches: [ main, dev ]
    paths:
      - 'release/src/**'
      - 'release/src-rt-5.04behnd.4916/**'
      - '.github/workflows/build.yml'
  pull_request:
    branches: [ main ]
  workflow_dispatch:  # 手动触发

env:
  TOOLCHAIN_PATH: /opt/toolchains/crosstools-arm_softfp-gcc-10.3-linux-4.19-glibc-2.32-binutils-2.36.1
  SDK_DIR: release/src-rt-5.04behnd.4916
  BUILD_TARGET: TUF-BE3600_V2

jobs:
  build:
    runs-on: [self-hosted, asus-build]
    timeout-minutes: 360  # 6小时超时

    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          fetch-depth: 0  # 完整历史（needed for version info）

      - name: Verify Toolchain
        run: |
          ${{ env.TOOLCHAIN_PATH }}/usr/bin/arm-buildroot-linux-gnueabi-gcc --version
          echo "Toolchain OK"

      - name: Set Environment
        run: |
          echo "${{ env.TOOLCHAIN_PATH }}/usr/bin" >> $GITHUB_PATH
          export CROSS_COMPILE=arm-buildroot-linux-gnueabi-
          export ARCH=arm

      - name: Clean Build
        if: github.event_name == 'workflow_dispatch'
        run: |
          cd ${{ env.SDK_DIR }}
          make ${{ env.BUILD_TARGET }} clean || true

      - name: Build Firmware
        run: |
          cd ${{ env.SDK_DIR }}
          make ${{ env.BUILD_TARGET }} -j$(nproc) 2>&1 | tee build.log
        env:
          CROSS_COMPILE: arm-buildroot-linux-gnueabi-
          ARCH: arm

      - name: Check Build Output
        run: |
          cd ${{ env.SDK_DIR }}/image
          ls -lh *.trx *.bin 2>/dev/null || echo "No firmware found!"
          echo "=== Build Artifacts ==="
          find . -name "*.trx" -o -name "*.bin" -o -name "*.img" | head -20

      - name: Upload Firmware
        uses: actions/upload-artifact@v4
        with:
          name: TUF-BE3600_V2-${{ github.sha }}
          path: |
            ${{ env.SDK_DIR }}/image/*.trx
            ${{ env.SDK_DIR }}/image/*.bin
          retention-days: 30

      - name: Upload Build Log (on failure)
        if: failure()
        uses: actions/upload-artifact@v4
        with:
          name: build-log-${{ github.sha }}
          path: ${{ env.SDK_DIR }}/build.log
          retention-days: 7

  # 可选: 自动发布 Release
  release:
    needs: build
    if: startsWith(github.ref, 'refs/tags/v')
    runs-on: ubuntu-latest
    permissions:
      contents: write
    steps:
      - name: Download Firmware
        uses: actions/download-artifact@v4
        with:
          name: TUF-BE3600_V2-${{ github.sha }}

      - name: Create Release
        uses: softprops/action-gh-release@v2
        with:
          tag_name: ${{ github.ref_name }}
          name: "TUF-BE3600 V2 ${{ github.ref_name }}"
          body: |
            ## TUF-BE3600 V2 魔改固件 ${{ github.ref_name }}

            ### 变更内容
            - 基于最新修改计划 (doc/02_MODIFICATION_PLAN.md)

            ### 刷入方法
            1. 登录路由器 Web 管理 (192.168.50.1)
            2. 系统管理 → 固件更新 → 上传 .trx 文件
            3. 等待重启完成

            ### 注意事项
            - 首次刷入建议恢复出厂设置
            - 已移除 ASD/AHS/FRS/Alexa/IoT 组件
          files: "*.trx"
          draft: true
```

### 7.5 Workflow 说明

| 步骤 | 说明 |
|------|------|
| `on.push` | 仅在 `release/src/` 或 SDK 目录变更时触发，避免无关提交触发构建 |
| `workflow_dispatch` | 手动触发，配合 `clean` 步骤可执行全量重新编译 |
| `timeout-minutes: 360` | HND 固件首次全量编译可能需要 2-4 小时 |
| `build.log` | 编译日志完整保存，失败时上传供排查 |
| `upload-artifact` | 固件产物保留 30 天，可从 Actions 页面下载 |
| `release` job | 仅在推送 `v*` tag 时自动创建 GitHub Release |

### 7.6 常用命令

```bash
# 手动触发编译（通过 GitHub CLI）
gh workflow run build.yml -f clean=true

# 查看运行状态
gh run list --workflow=build.yml

# 下载最新编译产物
gh run download --workflow=build.yml -n TUF-BE3600_V2-*

# 推送 tag 触发 Release
git tag v1.0.0
git push origin v1.0.0
```

### 7.7 磁盘空间管理

GitHub-Hosted Runner 默认磁盘空间有限，需在 workflow 开头清理空间：

```yaml
- name: Free Disk Space
  if: runner.os == 'Linux'
  uses: jlumbroso/free-disk-space@main
  with:
    tool-cache: false
    docker-images: true
    large-packages: true
    swap-storage: true
```

### 7.8 工具链版本管理（可选）

将工具链压缩包上传到 GitHub Releases 或私有存储，在 workflow 中动态下载：

```yaml
- name: Download Toolchain
  run: |
    if [ ! -d "${{ env.TOOLCHAIN_PATH }}" ]; then
      wget -q "https://github.com/YOUR_USERNAME/toolchains/releases/download/v1.0/crosstools-arm-10.3.tar.xz"
      sudo tar xf crosstools-arm-10.3.tar.xz -C /opt/
    fi
```
