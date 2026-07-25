# ASUS TUF-BE3600 V2 魔改固件项目概述

## 项目定位

基于 ASUS 官方 GPL 源码，对 **TUF-BE3600 V2** (BCM6764) 路由器固件进行深度魔改，解锁所有官方隐藏的高级功能，增强 WiFi 7 性能与 CPU 调度能力，并整合此前开发的三个插件（cpupower、multiwand、vlan）直接内置到固件中。

**核心特性**：
- 移除 ASUS 云服务组件 (ASD/AHS/FRS/AWS IoT/Alexa/Google Assistant)
- 禁用自动更新和更新检测
- 管理界面默认对 LAN 和 WAN 开放
- AP 模式下支持 IP 直接访问 + 手机 App 局域网发现
- AiMesh 模式下支持节点 IP 管理
- 深度内核联动：dnsmasq+ipset、base64、802.1Q VLAN、端口聚合、加密模块
- 三个插件从 koolshare dbus 格式彻底转为原生 NVRAM 存储 + RC 服务集成

## 源码概况

| 项目 | 值 |
|------|-----|
| 目标机型 | **TUF-BE3600 V2** |
| 型号 ID | `MODEL_RTBE58U_V2` (与 RT-BE58U V2 / RT-BE55 共享) |
| SoC | **Broadcom BCM6764** (Quad-Core ARM Cortex-A7, BCM4916 家族) |
| Switch | **Realtek RTL8372** (rtkswitch) for 2.5G + 1G LAN |
| WiFi | BCM6764 integrated (2.4G+5G, **WiFi 7 802.11be**, MLO) |
| 外部 PHY | BCM84880 |
| Kernel | Linux 4.19 |
| SDK | Broadcom HND 5.04L.04p3 (96764GW 配置) |
| 内存 | 512MB DDR |
| NAND | 128KB NVSIZE, UBI/UBIFS |
| 构建命令 | `cd release/src-rt-5.04behnd.4916 && make TUF-BE3600_V2` |
| 编译前缀 | `TUFBE3600_V2` (C 预处理器宏) |
| 交叉编译链 | arm-buildroot-linux-gnueabi- (GCC 10.3, glibc 2.32) |
| 交叉编译链路径 | `/opt/toolchains/crosstools-arm_softfp-gcc-10.3-linux-4.19-glibc-2.32-binutils-2.36.1/usr/bin/` |

## 源代码目录结构

```
asus-tuf-v2-dahi/
├── README.TXT                    # 官方构建说明
├── buildtools/                   # 构建辅助工具
├── release/
│   ├── src/                      # ASUSWRT 用户态代码
│   │   └── router/
│   │       ├── rc/               # 系统初始化与服务管理
│   │       ├── httpd/            # Web 服务器 (处理 ASP/CGI)
│   │       ├── shared/           # 共享库与预构建对象
│   │       ├── www/              # Web 前端 (ASP/JS/CSS/图片)
│   │       └── [258个组件目录]
│   ├── src-rt/                   # 旧式 MIPS 平台 (本项不使用)
│   ├── src-rt-5.04behnd.4916/    # Broadcom HND SDK (本项核心平台)
│   │   ├── kernel/linux-4.19/    # Linux 4.19 内核完整源码
│   │   ├── bcmdrivers/           # Broadcom 专属驱动
│   │   ├── router-sysdep/        # 系统依赖组件
│   │   ├── bootloaders/          # U-Boot 2019.07 + ARM TF
│   │   ├── targets/              # 各机型配置文件与 NVRAM
│   │   └── Makefile              # 主构建文件 (7363行)
│   └── image/                    # 固件打包
└── toolchain/                    # 旧式 MIPS 工具链 (本项不使用)
```

## 关键文件定位

| 组件 | 路径 (相对于 release/src-rt-5.04behnd.4916/) |
|------|---------|
| 构建目标定义 | `target.mak` (release/src-rt/ 下) 第150行 |
| 芯片配置 | `chip_profile.mak` 第58行 `TUF-BE3600_V2_CHIP_PROFILE=6764` |
| 内核配置 | `targets/96764GW/96764GW.TUF-BE3600_V2` |
| NVRAM 默认 | `targets/nvram/6764/TUF-BE3600_V2.nvm` |
| 设备树 | `kernel/dts/6764/6764.dtsi` (SoC级) |
| Bootloader 环境 | `bootloaders/build/configs/env_NAND_2M_TUF-BE3600_V2.conf` |
| U-Boot 选项 | `bootloaders/build/configs/options_6764_nand.conf.TUF-BE3600_V2` |
| 模型初始化 | `release/src/router/rc/init.c` (约 20054-20192行) |
| LED 温度传感器 DTS | `kernel/dts/6764/6764.dtsi` 中 `therm0: brcm-therm` |

## Web UI 主题系统

| 主题 | 目录 | 标志位 | 主色调 |
|------|------|--------|--------|
| TUF_UI | `www/sysdep/FUNCTION/TUF_UI/` | `tuf` (rc_support) | 橙色 `#D0982C` |
| ROG_UI | `www/sysdep/FUNCTION/ROG_UI/` | `rog` (rc_support) | 红色 `#FF3535` |
| UI4 | `www/sysdep/FUNCTION/UI4/` | `UI4` | 蓝色 `#248dff` |
| TS_UI | `www/sysdep/FUNCTION/TS_UI/` | TUF衍生 | 青色 `#2ED9C3` |

当前 TUF-BE3600 V2 固定使用 TUF_UI 主题（`TUF_UI=y`）。

## 已有插件（来自 C:\Users\Dahi\Documents\asuswrt）

这三个插件原为 koolshare 软件中心格式，将被深度内置整合进固件：

| 插件 | 功能 | 语言 | 改造要点 |
|------|------|------|----------|
| **cpupower** | CPU 调度控制、频率管理、温度监控 | Shell + ASP | dbus→NVRAM, RC 服务化, EJ 路由 |
| **multiwand** | 多 WAN 管理 (PPPoE/DHCP/静态IP/策略路由) | Shell + ASP | dbus→NVRAM, 集成到 rc/services.c 和 firewall.c |
| **vlan** | VLAN 管理 (802.1Q/端口绑定/端口聚合) | Shell + ASP | dbus→NVRAM, 集成到 init-broadcom.c |

## 关键设计原理：rc_support 特性开关

ASUSWRT 使用 NVRAM 变量 `rc_support`（空格分隔的关键词字符串）作为运行时特性开关：
- **启动时** init.c 中根据型号添加标志位
- **后端 C 代码** 使用 `nvram_contains_word("rc_support", "flag")` 判断
- **前端 JS** 使用 `isSupport("flag")` 判断 UI 可见性

当前 TUF-BE3600 V2 的 rc_support = `mssid 2.4G 5G update usbX1 switchctrl manual_stb 11AX pwrctrl nandflash movistarTriple wifi2017 app ofdma wpa3`
