# ASUS TUF-AX3600_V2 魔改固件 - 项目任务交接文档

> **生成日期**: 2026-07-29  
> **项目状�?*: 可编�?✅（但固件不可用�? 
> **源码版本**: ASUS GPL `GPL_TUF-3600_V2_3.0.0.6.102.39099-gd8de8b3_1283-ge738b_BB0C.tgz`  
> **仓库**: `https://github.com/builderjamdh/asu-tuf-vii`

---

## 一、项目概�?
### 1.1 目标
基于 ASUS 官方 GPL 源码，对 **TUF-AX3600 V2 (BCM6764)** 路由器固件进行深度魔改，解锁所有官方隐藏的高级功能，增�?WiFi 7 性能�?CPU 调度能力�?
### 1.2 硬件规格
| 组件 | 规格 |
|------|------|
| SoC | Broadcom BCM6764 (Quad-Core ARM Cortex-A7, BCM4916 家族) |
| Switch | Realtek RTL8372 (2.5G + 1G LAN) |
| WiFi | BCM6764 integrated (2.4G+5G, WiFi 7 802.11be, MLO) |
| 外部 PHY | BCM84880 |
| 内存 | 512MB DDR |
| NAND | 128KB NVSIZE, UBI/UBIFS |
| Kernel | Linux 4.19 |
| SDK | Broadcom HND 5.04L.04p3 (96764GW 配置) |

### 1.3 核心修改计划�?5 项）

| 编号 | 模块 | 状�?| 优先�?| 说明 |
|------|------|------|--------|------|
| M01 | 清理冗余文件 | 待实�?| P0 | 删除旧平台文件、无用组件、过时代�?|
| M02 | 解锁 rc_support 隐藏功能 | 部分完成 | P0 | 已添加标志位�?init.c，仍需适配�?TUF-AX3600 V2 |
| M03 | WiFi 国家/区域/信道全解�?| 部分完成 | P0 | 内核 CPUFREQ 已启用，WiFi 解锁待适配 BCM6764 |
| M04 | WiFi 功率增强 | 待实�?| P0 | 移除功率上限与节能逻辑（BCM6764 + RTL8372�?|
| M05 | CPU 调度与温度管�?| 部分完成 | P0 | 内核 cpufreq 已启用，待适配 BCM6764 thermal |
| M06 | 华硕云控总开�?| 已实�?| P1 | NVRAM 变量 + gating 已添�?|
| M07 | 高级交换机控�?(RTL8372) | 待实�?| P1 | 端口镜像、Flow Control、端口速度强制 |
| M08 | UPnP 带宽限�?| 待实�?| P1 | 新增 UPnP 带宽控制 UI 和限速逻辑 |
| M09 | STUN 自定�?| 待实�?| P1 | STUN 服务器自定义、接口选择 |
| M10 | FullCone NAT 防火墙模�?| 待实�?| P1 | 启用 FullCone NAT 并作为默认选项 |
| M11 | 移除网络神盾 (AiProtection) | 待实�?| P1 | 可选移�?TrendMicro bwdpi 组件 |
| M12 | UU 加速器 AP 模式 + WOL 持久�?| 待实�?| P1 | AP 模式下保�?UU + WOL 服务不断 |
| M13 | 首页面板增强 | 待实�?| P1 | CPU 温度/网卡温度/CPU 频率/功率显示 |
| M14 | DFS 信道指定套件 | 待实�?| P2 | DFS 信道手动选择、雷达日�?|
| M15 | CPU 频率管理套件 (内置 cpupower) | 待实�?| P2 | CPU 调速器面板、频率自定义 |
| M16 | �?WAN 管理 (内置 multiwand) | 待实�?| P2 | �?WAN 拨号 + 策略路由 |
| M17 | VLAN 管理套件 (内置 vlan) | 待实�?| P2 | 802.1Q VLAN、端口聚合、VLAN 配置 |
| M18 | 增强错误日志系统 | 待实�?| P2 | UI 实时日志查看、持久化日志 |
| M19 | 主题系统 | 待实�?| P2 | 主题切换 (TUF/ROG/ASUS/自定�? |
| M20 | Pro 高级功能选项 | 待实�?| P3 | 各类隐藏 Pro 选项全开 |
| M21 | 移除 ASD / AHS 组件 | 已实�?| P1 | 移除 ASUS 诊断服务 ASD 和心跳服�?AHS |
| M22 | 更新 curl 组件 | 待实�?| P1 | 升级 curl 到最新稳定版 |
| M23 | 移除 AWS IoT 智能家居 | 已实�?| P1 | 移除亚马�?AWS IoT 智能家居集成 |
| M24 | 禁用自动更新 / 更新检�?| 已实�?| P0 | 禁用固件自动更新和更新检�?|
| M25 | 优化后台字体 | 待实�?| P2 | Web 管理后台字体优化 |
| M26 | 开放管理界�?(LAN+WAN) | 待实�?| P0 | 管理界面默认�?LAN �?WAN 均开�?|
| M27 | AiMesh 节点 IP 管理 | 待实�?| P1 | AiMesh 模式下使用节�?IP 访问 Web 管理 |
| M28 | AP 模式 IP 访问 + 手机 App 发现 | 待实�?| P0 | AP 模式保留 IP 访问，手�?App 可局域网发现 |
| M29 | 三插件深度内核联�?| 待实�?| P0 | cpupower/multiwand/vlan 与内�?底层深度联动 |
| M30 | DNSMasq + ipset + base64 + 内核模块嵌入 | 待实�?| P0 | 深度嵌入并启�?dnsmasq ipset, base64 及必要内核模�?|
| M31 | 移除华硕反馈 (FRS) 功能 | 已实�?| P0 | 移除 FRS_FEEDBACK 反馈上报组件 |
| M32 | koolcenter 缺失内核依赖补全 | 已实�?| P1 | 内核配置补全 |
| M33 | BBR TCP 加�?+ 状态显�?| 已实�?| P1 | BBR 拥塞控制 |
| M34 | AP 模式 WAN 端口硬件转发优化 | 已实�?| P1 | AP 模式桥接硬件转发 |
| M35 | 防火墙自定义规则管理 | 已实�?| P1 | Web 界面管理自定�?iptables 规则 |

---

## 二、源码对比分�?
### 2.1 官方 GPL tarball vs GitHub 仓库

| 组件 | 官方 tarball | GitHub 仓库 | 差异 | 状�?|
|------|-------------|------------|------|------|
| **router-sysdep 目录** | 92 �?| 66 �?| �?�?26 �?| 空目录占位符 |
| **kernel 子目�?* | linux-4.19 + **bcmkernel + dts** | �?linux-4.19 | �?�?bcmkernel + dts | **关键缺失** |
| **hostTools 子目�?* | **360 个文�?* | 347 个文�?| �?�?13 �?| squashfs_4.2 等工�?|
| **prebuilt .o 文件** | 6 �?(avs/dhd/emf/hnd/igs/wl) | 6 个（相同�?| �?一�?| 闭源预编�?|
| **bootloaders** | 一�?| 一�?| �?一�?| U-Boot + ARM TF |
| **rdp** | 一�?| 一�?| �?一�?| RDP 项目文件 |

### 2.2 bcmdrivers 差异

| 路径 | 官方 | GitHub | 缺失 | 重要�?|
|------|------|--------|------|--------|
| `bcmdrivers/broadcom/char` | 984 | 905 | 79 | �?|
| `bcmdrivers/broadcom/net` | 5943 | 5777 | 166 | **�?* |
| `bcmdrivers/broadcom/net/wl/impl105` | 5755 | 5591 | 164 | **🔴 关键** |
| `bcmdrivers/broadcom/net/wl/impl105/main/components/phy` | 108 | 5 | **103** | **🔴🔴 极度关键** |
| `bcmdrivers/broadcom/net/wl/impl105/main/components/phy/ac` | 存在 | **缺失** | 全部 | **WiFi PHY AC �?* |
| `bcmdrivers/broadcom/net/wl/impl105/main/components/phy/cmn` | 存在 | **缺失** | 全部 | **WiFi PHY 公共�?* |
| `bcmdrivers/broadcom/net/wl/impl105/main/components/avs` | 存在 | **缺失** | 全部 | **ASUS Wireless Security** |
| `bcmdrivers/broadcom/net/wl/impl105/main/components/clm-api` | 存在 | **缺失** | 全部 | **信道列表管理** |
| `bcmdrivers/broadcom/net/wl/impl105/main/components/pasn` | 存在 | **缺失** | 全部 | **认证服务** |
| `bcmdrivers/broadcom/net/wl/impl105/main/components/shared` | 存在 | **缺失** | 全部 | **WiFi 共享组件** |
| `rdp/drivers` | 994 | 807 | 187 | �?|
| `rdp/firmware` | 126 | 110 | 16 | �?|

### 2.3 完全缺失的目录（官方 tarball 中有�?
| 路径 | 说明 | 重要�?| 官方 tarball 状�?|
|------|------|--------|------------------|
| `bcmdrivers/broadcom/char/bcmprocfs` | BCM 进程文件系统 | �?| �?已同步（空目录） |
| `bcmdrivers/broadcom/char/gpon` | GPON 驱动 | �?(TUF �?DSL) | �?已同步（空目录） |
| `bcmdrivers/broadcom/char/sata_test` | SATA 测试工具 | �?| �?已同步（空目录） |
| `bcmdrivers/broadcom/char/tms` | TMS 驱动 | �?| �?已同步（空目录） |
| `bcmdrivers/broadcom/char/xtmcfg` | XTM 配置 | �?| �?已同步（空目录） |
| `bcmdrivers/broadcom/net/eapfwd` | EAP 转发�?| �?| �?已同步（空目录） |
| **`bcmdrivers/broadcom/net/wl/impl105/main/components/phy/ac`** | **WiFi PHY AC �?* | **🔴🔴 极度关键** | ⚠️ 空目录占位符�?0 个子目录，无文件�?|
| **`bcmdrivers/broadcom/net/wl/impl105/main/components/phy/cmn`** | **WiFi PHY 公共�?* | **🔴🔴 极度关键** | ⚠️ 空目录占位符�?1 个子目录，无文件�?|
| **`bcmdrivers/broadcom/net/wl/impl105/main/components/avs`** | **ASUS Wireless Security** | **🔴🔴 极度关键** | ⚠️ 空目录占位符�? 个子目录，无文件�?|
| **`bcmdrivers/broadcom/net/wl/impl105/main/components/clm-api`** | **信道列表管理** | **🔴🔴 极度关键** | ⚠️ 空目录占位符�? 个子目录，无文件�?|
| **`bcmdrivers/broadcom/net/wl/impl105/main/components/pasn`** | **认证服务** | **🔴🔴 极度关键** | ⚠️ 空目录占位符�? 个子目录，无文件�?|
| **`bcmdrivers/broadcom/net/wl/impl105/main/components/shared`** | **WiFi 共享组件** | **🔴🔴 极度关键** | ⚠️ 空目录占位符�? 个子目录，无文件�?|
| `bcmdrivers/broadcom/net/wl/impl105/main/components/apps/escand` | Escan 扫描 | �?| �?已同步（空目录） |
| `bcmdrivers/broadcom/net/wl/impl105/main/components/apps/visualization` | WiFi 可视�?| �?| �?已同步（2 个子目录，无文件�?|
| `bcmdrivers/broadcom/net/wl/impl105/main/components/apps/wldm` | WiFi 设备管理 | �?| �?已同步（空目录） |

> **重要发现**：官�?GPL tarball �?phy/ac、phy/cmn、avs、clm-api、pasn、shared 等目�?*都是空目录占位符**（只有子目录结构，没�?.c/.h/.mk 文件）。这些文件是 ASUS 内部闭源源码的一部分，不会出现在 GPL 发布版中�?
### 2.4 官方 tarball 限制

| 限制 | 说明 |
|------|------|
| **bcmkernel/dts 缺失** | GPL 许可证限制，内核驱动源码不包含在 GPL tarball �?|
| **phy/ac、phy/cmn 为空** | WiFi PHY 层是闭源组件，GPL tarball 中只有空目录占位�?|
| **avs、clm-api、pasn、shared 为空** | ASUS Wireless Security 和信道管理是闭源组件 |
| **prebuilt .o 只有 6 �?* | 80+ 个预编译 .o 文件是闭源二进制，不会出现在 GPL tarball �?|
| **hostTools 不完�?* | 部分 hostTools（如 squashfs_4.2、cramfs、imgbin2hex）在 GPL tarball 中存�?|

### 2.5 部分缺失（官�?tarball 中有�?GitHub 不完整）

| 路径 | 官方 | GitHub | 缺失 |
|------|------|--------|------|
| `bcmdrivers/broadcom/net/wl/impl105/main/components/apps` | 234 | 210 | 24 |
| `bcmdrivers/broadcom/net/wl/impl105/main/components/phy` | 108 | 5 | **103!** |
| `bcmdrivers/broadcom/net/wl/impl105/main/components/msch` | 4 | 3 | 1 |
| `bcmdrivers/broadcom/net/wl/impl105/cmwifi` | 140 | 133 | 7 |
| `bcmdrivers/broadcom/net/wl/impl105/main/src` | 295 | 284 | 11 |
| `bcmdrivers/broadcom/net/wl/impl105/main` (总计) | 5612 | 5455 | 157 |
| `bcmdrivers/broadcom/net/wl/impl105` (总计) | 5755 | 5591 | 164 |
| `rdp/drivers` | 994 | 807 | 187 |
| `rdp/firmware` | 126 | 110 | 16 |
| `rdp/projects` | 1695 | 1694 | 1 |
| `hostTools` | 360 | 347 | 13 |
| `data-model` | 34 | 23 | 11 |

---

## 三、编译失败根因分�?
### 3.1 编译日志核心错误�?
```
1. platform.mak 执行 setprofile 阶段
2. 尝试 cp 80+ 个文�?�?全部 "cannot stat"
3. Busybox Kconfig ncurses 检查失�?4. make[2]: *** [Makefile:7163: setprofile] Error 2
5. 构建终止
6. 但后续仍有部分组件编�?�?产生 55MB 不完整的 .pkgtb
```

### 3.2 关键错误示例

```
cp: cannot stat '/home/dahi/actions-runner/_work/asu-tuf-vii/asu-tuf-vii/release/src-rt-5.04behnd.4916/bcmdrivers/broadcom/net/wl/bcm96764/main/src/router-sysdep/hnd_extra/prebuilt/bcm_enet.o': No such file or directory
cp: cannot stat '/home/dahi/actions-runner/_work/asu-tuf-vii/asu-tuf-vii/release/src-rt-5.04behnd.4916/bcmdrivers/broadcom/net/wl/bcm96764/main/src/router-sysdep/hnd_extra/prebuilt/wfd.o': No such file or directory
... (80+ 个类似错�?
```

### 3.3 根因分析

**`cp: cannot stat` 的不�?prebuilt 目录的文件，而是 platform.mak 中期望从编译输出目录复制的文件�?*

platform.mak 中有这样的逻辑�?```makefile
cp $(TOP_PLATFORM)/hnd_extra/prebuilt/bcm_enet.o $(HND_SRC)/bcmdrivers/.../bcm_enet$(PRBM_EXT).o
```

这里 `PRBM_EXT=_pre`，所以它期望复制的是 `bcm_enet_pre.o` �?但这文件**不存在于 prebuilt 目录�?*。prebuilt 目录只有 6 个文件（avs.o, dhd.o, emf.o, hnd.o, igs.o, wl.o）�?
**这些 `bcm_enet.o`, `wfd.o`, `bdmf.o`, `rdpa.o` �?80+ 个文件应该是从各自的源目录编译后放置�?prebuilt 目录的，或者是�?ASUS 提供的闭源预编译二进制�?*

### 3.4 固件"能编译但不能�?的真正原�?
| 问题 | 影响 |
|------|------|
| **80+ �?Broadcom prebuilt 文件缺失** | 网卡驱动、BCM 总线管理、RDPA 硬件加速等核心功能完全缺失 |
| **Busybox setprofile/Kconfig 失败** | Busybox 工具链不完整 |
| **大量组件�?`-k` 被跳�?* | httpd、dropbear、各种库可能编译不完�?|
| **26 �?router-sysdep 目录缺失** | MDM（设备管理）、NAS（网络存储）、hnd_dpsta（双并发 STA）等功能缺失 |
| **bcmkernel �?dts 目录缺失** | 内核模块和设备树不完�?|
| **phy/ac + phy/cmn 缺失** | WiFi 物理层核心缺�?�?WiFi 驱动无法编译 |
| **avs + clm-api + pasn + shared 缺失** | WiFi 安全、信道管理、认证服务缺�?�?WiFi 功能不完�?|

---

## 四、修复方�?
### 4.1 方案 A：从官方 tarball 同步缺失内容（推荐）

```powershell
# 1. 同步缺失�?router-sysdep 目录
Copy-Item 'C:\Users\Dahi\Downloads\official_src\asuswrt\release\src-rt-5.04behnd.4916\router-sysdep\nas' -Destination 'release\src-rt-5.04behnd.4916\router-sysdep\' -Recurse -Force

# 2. 同步 bcmkernel �?dts（如果官�?tarball 中有�?Copy-Item 'C:\Users\Dahi\Downloads\official_src\asuswrt\release\src-rt-5.04behnd.4916\kernel\bcmkernel' -Destination 'release\src-rt-5.04behnd.4916\kernel\' -Recurse -Force
Copy-Item 'C:\Users\Dahi\Downloads\official_src\asuswrt\release\src-rt-5.04behnd.4916\kernel\dts' -Destination 'release\src-rt-5.04behnd.4916\kernel\' -Recurse -Force

# 3. 同步缺失�?hostTools
Copy-Item 'C:\Users\Dahi\Downloads\official_src\asuswrt\release\src-rt-5.04behnd.4916\hostTools\squashfs_4.2' -Destination 'release\src-rt-5.04behnd.4916\hostTools\' -Recurse -Force

# 4. 同步缺失�?bcmdrivers
Copy-Item 'C:\Users\Dahi\Downloads\official_src\asuswrt\release\src-rt-5.04behnd.4916\bcmdrivers\broadcom\net\wl\impl105\main\components\phy\ac' -Destination 'release\src-rt-5.04behnd.4916\bcmdrivers\broadcom\net\wl\impl105\main\components\phy\ac' -Recurse -Force
Copy-Item 'C:\Users\Dahi\Downloads\official_src\asuswrt\release\src-rt-5.04behnd.4916\bcmdrivers\broadcom\net\wl\impl105\main\components\phy\cmn' -Destination 'release\src-rt-5.04behnd.4916\bcmdrivers\broadcom\net\wl\impl105\main\components\phy\cmn' -Recurse -Force
# ... 其余缺失目录同理
```

### 4.2 方案 B：如果官�?tarball 也不完整

那说明缺失的 prebuilt .o 文件�?0+ 个）�?**ASUS 内部闭源二进�?*，不会出现在 GPL 发布版中。这种情况下�?- 你需要从第三方团队获取完整的 prebuilt 文件�?- 或者联�?ASUS 获取完整源码
- 或者尝试从其他 TUF-AX3000 V2 编译者的发布中获�?
### 4.3 方案 C：修�?platform.mak 跳过 prebuilt 依赖

如果无法获取 prebuilt 文件，可以修�?`platform.mak`�?1. 注释掉所�?`cp ... prebuilt/...` 命令
2. 改为从源目录直接编译
3. 但这需要大量修改，且可能引入新的编译错�?
---

## 五、CI/CD 配置

### 5.1 架构选择

ASUSWRT HND 固件编译需�?**30GB+ 磁盘空间** �?**8GB+ 内存**，且依赖 Broadcom 闭源交叉编译工具链（无法通过 apt 安装）。因此有两种 CI 方案�?
| 方案 | 优点 | 缺点 |
|------|------|------|
| **A: Self-Hosted Runner（推荐）** | 性能好、可复用工具链缓存、编译快 | 需要一台常开 Linux 机器 |
| **B: GitHub-Hosted Runner + 工具链缓�?* | 无需自备机器、免费额度内可用 | 首次编译慢（需下载工具链）、磁盘空间受�?|

**推荐方案 A**：在本地 WSL2 Ubuntu 或独�?Linux 服务器上部署 Self-Hosted Runner�?
### 5.2 Workflow 文件

在仓库根目录创建 `.github/workflows/build.yml`�?
```yaml
name: Build TUF-AX3600 V2 Firmware

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
  BUILD_TARGET: TUF-AX3600_V2

jobs:
  build:
    runs-on: [self-hosted, asus-build]
    timeout-minutes: 360  # 6 小时超时

    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          fetch-depth: 0  # 完整历史（needed for version info�?
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
          name: TUF-AX3600_V2-${{ github.sha }}
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

  # 可选：自动发布 Release
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
          name: TUF-AX3600_V2-${{ github.sha }}

      - name: Create Release
        uses: softprops/action-gh-release@v2
        with:
          tag_name: ${{ github.ref_name }}
          name: "TUF-AX3600 V2 ${{ github.ref_name }}"
          body: |
            ## TUF-AX3600 V2 魔改固件 ${{ github.ref_name }}

            ### 变更内容
            - 基于最新修改计�?(doc/02_MODIFICATION_PLAN.md)

            ### 刷入方法
            1. 登录路由�?Web 管理 (192.168.50.1)
            2. 系统管理 �?固件更新 �?上传 .trx 文件
            3. 等待重启完成

            ### 注意事项
            - 首次刷入建议恢复出厂设置
            - 已移�?ASD/AHS/FRS/AWS IoT 组件
          files: "*.trx"
          draft: true
```

### 5.3 Workflow 说明

| 步骤 | 说明 |
|------|------|
| `on.push` | 仅在 `release/src/` �?SDK 目录变更时触发，避免无关提交触发构建 |
| `workflow_dispatch` | 手动触发，配�?`clean` 步骤可执行全量重新编�?|
| `timeout-minutes: 360` | HND 固件首次全量编译可能需�?2-4 小时 |
| `build.log` | 编译日志完整保存，失败时上传供排�?|
| `upload-artifact` | 固件产物保留 30 天，可从 Actions 页面下载 |
| `release` job | 仅在推�?`v*` tag 时自动创�?GitHub Release |

### 5.4 常用命令

```bash
# 手动触发编译（通过 GitHub CLI�?gh workflow run build.yml -f clean=true

# 查看运行状�?gh run list --workflow=build.yml

# 下载最新编译产�?gh run download --workflow=build.yml -n TUF-AX3600_V2-*

# 推�?tag 触发 Release
git tag v1.0.0
git push origin v1.0.0
```

### 5.5 磁盘空间管理

GitHub-Hosted Runner 默认磁盘空间有限，需�?workflow 开头清理空间：

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

### 5.6 工具链版本管理（可选）

将工具链压缩包上传到 GitHub Releases 或私有存储，�?workflow 中动态下载：

```yaml
- name: Download Toolchain
  run: |
    if [ ! -d "${{ env.TOOLCHAIN_PATH }}" ]; then
      wget -q "https://github.com/YOUR_USERNAME/toolchains/releases/download/v1.0/crosstools-arm-10.3.tar.xz"
      sudo tar xf crosstools-arm-10.3.tar.xz -C /opt/
    fi
```

---

## 六、待办事项清�?
### 6.1 高优先级（P0�?
- [ ] **同步官方 tarball 缺失内容�?GitHub 仓库**（从官方 tarball 复制所有缺失的目录和文件）
- [ ] **验证编译**（同步后重新触发 CI，确�?80+ prebuilt 错误消失�?- [ ] **修复 Busybox setprofile/Kconfig 失败**（安�?ncurses 或使�?`make config` 替代 `make menuconfig`�?- [ ] **修复 `[: too many arguments` shell 语法错误**（检�?Makefile 中的条件判断语法�?- [ ] **解锁 rc_support 隐藏功能**（适配 TUF-AX3600 V2 �?rc_support 标志位）
- [ ] **开放管理界�?(LAN+WAN)**（defaults.c + init.c 修改�?- [ ] **AP 模式 IP 访问 + 手机 App 发现**（AP 模式下保�?Web 管理可达�?
### 6.2 中优先级（P1�?
- [ ] **WiFi 国家/区域/信道全解�?*（ACS 信道优化、Country Code 处理、WiFi 国家码自定义 UI�?- [ ] **WiFi 功率增强**（提升功率上限、关闭节能、添加功率显示）
- [ ] **CPU 调度与温度管�?*（BCM6764 内核配置适配�?- [ ] **FullCone NAT 默认启用**（defaults.c + init.c 修改�?- [ ] **UPnP 带宽限�?*（miniupnpd 扩展 + iptables tc 联动�?- [ ] **STUN 自定�?*（ministun 调用参数改为 NVRAM 读取�?- [ ] **移除 AiProtection / bwdpi**（编译时移除 TrendMicro 组件�?- [ ] **更新 curl 组件**（升级到最新稳定版�?- [ ] **三插件深度内核联�?*（cpupower/multiwand/vlan 与内�?底层深度联动�?
### 6.3 低优先级（P2/P3�?
- [ ] **DFS 信道指定套件**
- [ ] **CPU 频率管理套件 (内置 cpupower)**
- [ ] **�?WAN 管理 (内置 multiwand)**
- [ ] **VLAN 管理套件 (内置 vlan)**
- [ ] **增强错误日志系统**
- [ ] **主题系统**
- [ ] **Pro 高级功能选项**
- [ ] **首页面板增强**
- [ ] **优化后台字体**
- [ ] **AiMesh 节点 IP 管理**

---

## 七、关键文件定�?
| 组件 | 路径 (相对�?release/src-rt-5.04behnd.4916/) |
|------|---------|
| 构建目标定义 | `target.mak` (release/src-rt/ �? �?150 �?|
| 芯片配置 | `chip_profile.mak` �?58 �?`TUF-AX3600_V2_CHIP_PROFILE=6764` |
| 内核配置 | `targets/96764GW/96764GW.TUF-AX3600_V2` |
| NVRAM 默认 | `targets/nvram/6764/TUF-AX3600_V2.nvm` |
| 设备�?| `kernel/dts/6764/6764.dtsi` (SoC �? |
| Bootloader 环境 | `bootloaders/build/configs/env_NAND_2M_TUF-AX3600_V2.conf` |
| U-Boot 选项 | `bootloaders/build/configs/options_6764_nand.conf.TUF-AX3600_V2` |
| 模型初始�?| `release/src/router/rc/init.c` (�?20054-20192 �? |
| LED 温度传感�?DTS | `kernel/dts/6764/6764.dtsi` �?`therm0: brcm-therm` |
| 平台配置 | `platform.mak` (预编译文件分�?+ CONFIGURE 定义) |
| 主构建入�?| `Makefile` (7363 �? |

---

## 八、编译命�?
```bash
# 进入 HND SDK 目录
cd release/src-rt-5.04behnd.4916

# 编译 TUF-AX3600 V2 固件
make TUF-AX3600_V2
```

首次编译可能需�?2-4 小时（取决于机器性能）。后续增量编�?10-30 分钟�?
### 仅编译特定组�?
```bash
# 仅编译内�?cd release/src-rt-5.04behnd.4916
make TUF-AX3600_V2 kernel

# 仅编译用户�?(router)
make TUF-AX3600_V2 router

# 仅编�?RC 服务
cd release/src/router/rc
make -f Makefile TUF-AX3600_V2
```

### 清理构建

```bash
# 完全清理
cd release/src-rt-5.04behnd.4916
make TUF-AX3600_V2 clean

# 仅清�?kernel
make TUF-AX3600_V2 kernel_clean
```

---

## 九、固件产�?
编译成功后，固件文件通常位于�?
```
release/src-rt-5.04behnd.4916/image/
├── TUF-AX3600_V2_xxx.trx          # 主固�?(通过 Web UI 刷入)
└── TUF-AX3600_V2_xxx_cferom.bin   # �?CFE 的完整映�?(救援模式�?
```

---

## 十、刷入固�?
1. 登录路由�?Web 管理界面 (通常 `192.168.50.1`)
2. 进入「系统管理」→「固件更新�?3. 上传编译好的 `.trx` 文件
4. 等待刷入完成并自动重�?
**救援模式刷入**：按�?Reset 按钮通电，电源灯闪烁时通过 ASUS Firmware Restoration 工具上传固件�?
---

## 十一、常见问�?
### 编译错误：找不到 arm-buildroot-linux-gnueabi-gcc

�?工具链未安装�?PATH 未设置。检�?`/opt/toolchains/` 目录�?
### 编译错误：某�?.o 文件缺失

�?ASUS GPL 发布中部分闭源组件是预编�?.o 文件。检�?`release/src/router/*/prebuild/` 目录是否存在�?
### 编译成功但固件无法启�?
�?检�?CFE/NVRAM 兼容性。可通过串口 TTL 查看启动日志�?
### WSL2 编译�?
�?确保源码放在 WSL2 原生 ext4 文件系统中（�?/mnt/c/），否则 I/O 性能极差�?
---

## 十二、项目目录结�?
```
asus-tuf-v2-dahi/
├── README.TXT                    # 官方构建说明
├── buildtools/                   # 构建辅助工具
├── release/
�?  ├── src/                      # ASUSWRT 用户态代�?�?  �?  └── router/
�?  �?      ├── rc/               # 系统初始化与服务管理
�?  �?      ├── httpd/            # Web 服务�?(处理 ASP/CGI)
�?  �?      ├── shared/           # 共享库与预构建对�?�?  �?      ├── www/              # Web 前端 (ASP/JS/CSS/图片)
�?  �?      └── [258 个组件目录]
�?  ├── src-rt/                   # 旧式 MIPS 平台 (本项不使�?
�?  ├── src-rt-5.04behnd.4916/    # Broadcom HND SDK (本项核心平台)
�?  �?  ├── kernel/linux-4.19/    # Linux 4.19 内核完整源码
�?  �?  ├── bcmdrivers/           # Broadcom 专属驱动
�?  �?  ├── router-sysdep/        # 系统依赖组件
�?  �?  ├── bootloaders/          # U-Boot 2019.07 + ARM TF
�?  �?  ├── targets/              # 各机型配置文件与 NVRAM
�?  �?  └── Makefile              # 主构建文�?(7363 �?
�?  └── image/                    # 固件打包
└── toolchain/                    # 旧式 MIPS 工具�?(本项不使�?
```

---

## 十三、Web UI 主题系统

| 主题 | 目录 | 标志�?| 主色�?|
|------|------|--------|--------|
| TUF_UI | `www/sysdep/FUNCTION/TUF_UI/` | `tuf` (rc_support) | 橙色 `#D0982C` |
| ROG_UI | `www/sysdep/FUNCTION/ROG_UI/` | `rog` (rc_support) | 红色 `#FF3535` |
| UI4 | `www/sysdep/FUNCTION/UI4/` | `UI4` | 蓝色 `#248dff` |
| TS_UI | `www/sysdep/FUNCTION/TS_UI/` | TUF 衍生 | 青色 `#2ED9C3` |

当前 TUF-AX3600 V2 固定使用 TUF_UI 主题（`TUF_UI=y`）�?
---

## 十四、关键设计原理：rc_support 特性开�?
ASUSWRT 使用 NVRAM 变量 `rc_support`（空格分隔的关键词字符串）作为运行时特性开关：
- **启动�?* init.c 中根据型号添加标志位
- **后端 C 代码** 使用 `nvram_contains_word("rc_support", "flag")` 判断
- **前端 JS** 使用 `isSupport("flag")` 判断 UI 可见�?
当前 TUF-AX3600 V2 �?rc_support = `mssid 2.4G 5G update usbX1 switchctrl manual_stb 11AX pwrctrl nandflash movistarTriple wifi2017 app ofdma wpa3`

### 新增 rc_support 标志�?
| 标志�?| 功能 | 控制文件 |
|--------|------|----------|
| `tagged_based_vlan` | 802.1Q Tag-Based VLAN | state.js + menuTree |
| `mtlancfg` | VLAN Switch/Profile 页面 | state.js + menuTree |
| `vlan` | VLAN 支持声明 | 后端 |
| `lacp` | Link Aggregation | UI |
| `dfs` | DFS 信道支持 | UI + init-broadcom.c |
| `wifi7` | WiFi 7 显式支持 | UI |
| `wifi6e` | WiFi 6E 支持 | UI |
| `mumimo` | MU-MIMO | UI |
| `smart_connect` | 频段导航 v1 | UI |
| `smart_connect_v2` | 频段导航 v2 | UI |
| `reboot_schedule` | 定时重启 | UI |
| `dnsfilter` | DNS 过滤 | UI |
| `dnspriv` | DNS Privacy (DoT) | UI |
| `traffic_analyzer` | 流量分析 | UI |
| `traffic_limiter` | 流量限制 | UI |
| `dblog` | 诊断日志 | 后端 |
| `dhdlog` | DHD 驱动日志 | 后端 |
| `email` | 邮件通知 | UI |
| `nt_center` | 通知中心 | UI |
| `fullcone` | FullCone NAT | UI + firewall.c |
| `getrealip` | 真实 IP 获取 (STUN) | UI |
| `cloudcheck` | 云连接检�?| 后端 |
| `findasus` | ASUS 设备发现 | 后端 |
| `ssh` | SSH | UI |
| `snmp` | SNMP | UI |
| `ipv6` | IPv6 | UI |
| `ipv6pt` | IPv6 Pass-Through | UI |
| `v6option` | IPv6 选项 | UI |

---

## 十五、已有插件（来自 C:\Users\Dahi\Documents\asuswrt�?
这三个插件原�?koolshare 软件中心格式，将被深度内置整合进固件�?
| 插件 | 功能 | 语言 | 改造要�?|
|------|------|------|----------|
| **cpupower** | CPU 调度控制、频率管理、温度监�?| Shell + ASP | dbus→NVRAM, RC 服务化，EJ 路由 |
| **multiwand** | �?WAN 管理 (PPPoE/DHCP/静�?IP/策略路由) | Shell + ASP | dbus→NVRAM, 集成�?rc/services.c �?firewall.c |
| **vlan** | VLAN 管理 (802.1Q/端口绑定/端口聚合) | Shell + ASP | dbus→NVRAM, 集成�?init-broadcom.c |

---

## 十六、修改日志摘�?
### 已实施的修改

| 日期 | 模块 | 说明 |
|------|------|------|
| 2026-07-18 | M06 | 云控总开�?- 新增 NVRAM + Headers |
| 2026-07-18 | M06.1 | 云控总开�?- 启动时禁用所有云服务 |
| 2026-07-18 | M06.2 | 云控总开�?- 服务启动 gating |
| 2026-07-18 | M02.0 | rc_support 解锁 (TUF-AX3000 V2) |
| 2026-07-18 | M02.1 | rc_support 解锁 (TUF-AX3600 V2) |
| 2026-07-18 | M03/M04 | WiFi 解锁默认�?|
| 2026-07-18 | M05.0 | CPUFREQ 内核配置 |
| 2026-07-18 | M10.0 | FullCone NAT 默认启用 |
| 2026-07-18 | M11.0 | Network Shield / BWDPI 移除 |
| 2026-07-18 | M13.0 | Dashboard EJ 扩展函数 |
| 2026-07-18 | M21.0 | 移除 ASD/AHS 组件 |
| 2026-07-18 | M23.0 | 移除 AWS IoT 智能家居 |
| 2026-07-18 | M24.0 | 禁用自动更新 |
| 2026-07-18 | M25.0 | Web UI 字体优化 |
| 2026-07-18 | M26.0 | 开放管理界�?(LAN+WAN) |
| 2026-07-18 | M27.0 | AiMesh 节点 IP 管理 |
| 2026-07-18 | M28.0 | AP 模式 IP 访问 + App 发现 |
| 2026-07-18 | M29.0 | 三插件深度内核联�?|
| 2026-07-18 | M30.0 | DNSMasq ipset + 内核模块 |
| 2026-07-18 | M31.0 | 移除 FRS 反馈功能 |
| 2026-07-18 | M12.0 | UU/WOL AP 模式持久�?|
| 2026-07-18 | M08/M09 | UPnP 限�?+ STUN 自定�?|
| 2026-07-19 | M32 | koolcenter 缺失内核依赖补全 |
| 2026-07-19 | M33 | BBR TCP 加�?+ 状态显�?|
| 2026-07-19 | M34 | AP 模式 WAN 端口硬件转发优化 |
| 2026-07-19 | M35 | 防火墙自定义规则管理 |
| 2026-07-29 | CI-01 | 修复 varargs.h grep Bug（`grep -q "stdarg.h"` �?`grep -q '^#include'`�?|
| 2026-07-29 | CI-02 | Compile 步骤重设 CONFIG_SITE、CFLAGS、NOCONFIGURE 等环境变�?|
| 2026-07-29 | CI-03 | 串行重建 httpd/dropbear 时显式传�?CC 交叉编译�?|
| 2026-07-29 | CI-04 | 添加 httpd 二进制存在性验证，失败�?CI 终止 |

---

## 十七�?026-07-29 编译失败根因分析（最新）

### 分析对象
`C:\Users\Dahi\Downloads\logs_82329543767.zip` �?最近一�?CI 构建日志

### 根本原因

**问题 1：CONFIG_SITE 环境变量�?Compile (two-phase)"步骤中丢�?*

GitHub Actions 中每�?`run:` 步骤是独�?shell�?Build Firmware" 步骤设置�?`CONFIG_SITE=/tmp/config.site` 不会传递到"Compile (two-phase)" 步骤�?
`CONFIG_SITE` 文件包含 `ac_cv_prog_cc_works=yes` 等缓存变量，用于跳过 autotools 的交叉编译运行时测试。没有它，configure 脚本会尝试编译并运行测试程序，但 ARM 交叉编译器编译出的程序无法在 x86 主机上运�?�?全部�?"C compiler cannot create executables"�?
**问题 2：varargs.h 补丁存在 Bug**

```bash
# 旧代码（�?Bug�?grep -q "stdarg.h" "$f"  # 会匹配到 #error "Revise your code to use <stdarg.h>."
```

原始 varargs.h 内容包含 `#error "Revise your code to use <stdarg.h>."`，`grep -q "stdarg.h"` 会匹配到 error 消息中的 `stdarg.h`，误判为已补丁而跳过�?
**问题 3：串行重建（Serial rebuild）使用主�?gcc 而非交叉编译�?*

```bash
# Compile 步骤中串行重�?httpd �?make -C "$SRCDIR/router" -j1 -k httpd CONFIGURE="$CONFIGURE_OVERRIDE"
```

`CONFIGURE_OVERRIDE` 不包�?`CC=`，configure 找不�?`arm-buildroot-linux-gnueabi-gcc` �?fallback �?`/usr/bin/gcc`（主�?gcc），导致�?```
checking for arm-buildroot-linux-gnueabi-gcc... gcc
checking whether the C compiler works... no
configure: error: C compiler cannot create executables
```

**问题 4：构建失败但 CI 报告成功**

串行重建 httpd/dropbear 使用 `|| true` 掩盖了失败，导致 httpd 未编译但 CI 仍报�?"Build succeeded"�?
### 修复方案（已实施�?
| # | 修复�?| 文件 | 说明 |
|---|--------|------|------|
| 1 | 修复 varargs.h grep Bug | `.github/workflows/build.yml` L618-633 | `grep -q "stdarg.h"` �?`grep -q '^#include'` |
| 2 | Compile 步骤重设环境变量 | `.github/workflows/build.yml` | 添加 CONFIG_SITE、CFLAGS、NOCONFIGURE 等重�?|
| 3 | 串行重建传�?CC 参数 | `.github/workflows/build.yml` | `make ... httpd CC=...` 显式传递交叉编译器 |
| 4 | 添加 httpd 二进制验�?| `.github/workflows/build.yml` | 如果 httpd 未构建成功则 CI 失败 |

### 受影响包（全部因 CONFIG_SITE 缺失导致�?
| �?| 错误 | 影响 |
|---|------|------|
| libnetfilter_conntrack-1.0.7 | C compiler cannot create executables | httpd 依赖 |
| libnetfilter_cttimeout-1.0.0 | C compiler cannot create executables | conntrack 工具 |
| libnetfilter_queue | C compiler cannot create executables | 防火�?|
| libevent-2.0.21 | C compiler cannot create executables | 网络�?|
| lldpd-0.9.8 | C compiler cannot create executables | LLDP 协议 |
| openvpn | C compiler cannot create executables | VPN 服务 |
| inadyn | varargs.h error | DDNS 客户�?|
| db-4.8.30 | C compiler cannot create executables | 数据库库 |

---

## 十八、下一步行�?
### 立即行动（P0�?
1. **同步官方 tarball 缺失内容**（执�?sync.ps1 脚本或手动复制）
2. **验证编译**（重新触�?CI，确�?CONFIG_SITE 修复生效�?3. **修复 Busybox setprofile/Kconfig 失败**

### 短期行动（P1�?
4. **WiFi 解锁 + 功率增强**
5. **CPU 调度管理**
6. **FullCone NAT + UPnP + STUN**

### 中期行动（P2/P3�?
7. **三插件深度内核联�?*
8. **DFS 信道指定套件**
9. **主题系统**
10. **Pro 高级功能选项**

---

## 十八�?026-07-29 工作进展

### 已完�?1. �?生成 PROJECT_HANDOFF.md（覆�?AI_HANDOFF.md 全部内容�?2. �?从官�?tarball 同步 16 个缺失目录到 GitHub 仓库
3. �?提交更改（commit 9be894559�?
### 关键发现

**官方 GPL tarball �?phy/ac、phy/cmn、avs、clm-api、pasn、shared 等目录都是空目录占位符！**

这意味着�?- GPL tarball 中只有目录结构（50+ 个子目录），没有 .c/.h/.mk 文件
- 这些文件�?ASUS 内部闭源源码的一部分，不会出现在 GPL tarball �?- 第三方团队能编译出可用固件，是因为他们拥有完整的内部源码（包含所有预编译 .o 文件和闭源源码）

### 下一步行�?
1. **获取 ASUS 内部完整源码**（从第三方团队或 ASUS�?2. **或修�?platform.mak 跳过 prebuilt 依赖**（方�?C�?3. **或尝试从其他 TUF-AX3000 V2 编译者的发布中获�?*

---

## 十九、联系方�?
- **项目仓库**: `https://github.com/builderjamdh/asu-tuf-vii`
- **官方 GPL 源码**: `C:\Users\Dahi\Documents\asuswrt\GPL_TUF-3600_V2_3.0.0.6.102.39099-gd8de8b3_1283-ge738b_BB0C.tgz`
- **官方 tarball 解压目录**: `C:\Users\Dahi\Downloads\official_src\asuswrt`
- **编译日志目录**: `C:\Users\Dahi\Downloads\logs_extracted\build`

---

## 二十、附�?
### A. 工具链信�?
| 工具�?| 路径 | 用�?|
|--------|------|------|
| 主工具链 | `/opt/toolchains/crosstools-arm_softfp-gcc-10.3-linux-4.19-glibc-2.32-binutils-2.36.1` | 主构建（内核/用户态） |
| ARM TF 工具�?| `/opt/toolchains/crosstools-arm-gcc-10.3-linux-4.19-glibc-2.32-binutils-2.36.1` | ARM Trusted Firmware（安�?bootloader�?|
| OPTEE 工具�?| `/opt/toolchains/crosstools-aarch64-gcc-10.3-linux-4.19-glibc-2.32-binutils-2.36.1` | OPTEE（secureos�?|

### B. 构建环境变量

```bash
export PATH="/opt/toolchains/crosstools-arm_softfp-gcc-10.3-linux-4.19-glibc-2.32-binutils-2.36.1/usr/bin:$PATH"
export CROSS_COMPILE="arm-buildroot-linux-gnueabi-"
export ARCH="arm"
export TOOLCHAIN_BASE="/opt/toolchains"
export LD_LIBRARY_PATH="/opt/toolchains/crosstools-arm_softfp-gcc-10.3-linux-4.19-glibc-2.32-binutils-2.36.1/usr/lib"
```

### C. 编译前检查清�?
- [ ] 工具链已安装�?PATH 正确
- [ ] 所有缺失目录已从官�?tarball 同步
- [ ] 符号链接已正确创建（bcm96764 �?impl105�?- [ ] prebuilt 目录有所有必需�?.o 文件
- [ ] hostTools 工具有可执行权限
- [ ] 磁盘空间充足�?0GB+�?- [ ] 内存充足�?GB+�?
---

**文档结束**

> 本文档覆�?AI_HANDOFF.md 的全部内容，并增加了源码对比分析、编译失败根因、修复方案、待办事项清单等详细信息�?
