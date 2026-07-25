# ASUS TUF-BE3600 V2 魔改固件 - 完整修改计划

---

## 修改总览

| 编号 | 模块 | 状态 | 优先级 | 说明 |
|------|------|------|--------|------|
| M01 | 清理冗余文件 | 待实施 | P0 | 删除旧平台文件、无用组件、过时代码 |
| M02 | 解锁 rc_support 隐藏功能 | **部分完成** | P0 | 已添加标志位到 init.c，仍需适配到 TUF-BE3600 V2 |
| M03 | WiFi 国家/区域/信道全解锁 | **部分完成** | P0 | 内核 CPUFREQ 已启用，WiFi 解锁待适配 BCM6764 |
| M04 | WiFi 功率增强 | 待实施 | P0 | 移除功率上限与节能逻辑（BCM6764 + RTL8372） |
| M05 | CPU 调度与温度管理 | **部分完成** | P0 | 内核 cpufreq 已启用，待适配 BCM6764 thermal |
| M06 | 华硕云控总开关 | **部分完成** | P1 | NVRAM 变量 + gating 已添加 |
| M07 | 高级交换机控制 (RTL8372) | 待实施 | P1 | 端口镜像、Flow Control、端口速度强制 |
| M08 | UPnP 带宽限速 | 待实施 | P1 | 新增 UPnP 带宽控制 UI 和限速逻辑 |
| M09 | STUN 自定义 | 待实施 | P1 | STUN 服务器自定义、接口选择 |
| M10 | FullCone NAT 防火墙模式 | 待实施 | P1 | 启用 FullCone NAT 并作为默认选项 |
| M11 | 移除网络神盾 (AiProtection) | 待实施 | P1 | 可选移除 TrendMicro bwdpi 组件 |
| M12 | UU 加速器 AP 模式 + WOL 持久化 | 待实施 | P1 | AP 模式下保持 UU + WOL 服务不断 |
| M13 | 首页面板增强 | 待实施 | P1 | CPU温度/网卡温度/CPU频率/功率显示 |
| M14 | DFS 信道指定套件 | 待实施 | P2 | DFS 信道手动选择、雷达日志 |
| M15 | CPU 频率管理套件 (内置 cpupower) | 待实施 | P2 | CPU 调速器面板、频率自定义 |
| M16 | 多 WAN 管理 (内置 multiwand) | 待实施 | P2 | 多 WAN 拨号 + 策略路由 |
| M17 | VLAN 管理套件 (内置 vlan) | 待实施 | P2 | 802.1Q VLAN、端口聚合、VLAN 配置 |
| M18 | 增强错误日志系统 | 待实施 | P2 | UI 实时日志查看、持久化日志 |
| M19 | 主题系统 | 待实施 | P2 | 主题切换 (TUF/ROG/ASUS/自定义) |
| M20 | Pro 高级功能选项 | 待实施 | P3 | 各类隐藏 Pro 选项全开 |
| M21 | 移除 ASD / AHS 组件 | 待实施 | P1 | 移除 ASUS 诊断服务 ASD 和心跳服务 AHS |
| M22 | 更新 curl 组件 | 待实施 | P1 | 升级 curl 到最新稳定版 |
| M23 | 移除 AWS IoT 智能家居 | 待实施 | P1 | 移除亚马逊 AWS IoT 智能家居集成 |
| M24 | 禁用自动更新 / 更新检测 | 待实施 | P0 | 禁用固件自动更新和更新检测 |
| M25 | 优化后台字体 | 待实施 | P2 | Web 管理后台字体优化 |
| M26 | 开放管理界面 (LAN+WAN) | 待实施 | P0 | 管理界面默认对 LAN 和 WAN 均开放 |
| M27 | AiMesh 节点 IP 管理 | 待实施 | P1 | AiMesh 模式下使用节点 IP 访问 Web 管理 |
| M28 | AP 模式 IP 访问 + 手机 App 发现 | 待实施 | P0 | AP 模式保留 IP 访问, 手机 App 可局域网发现 |
| M29 | 三插件深度内核联动 | 待实施 | P0 | cpupower/multiwand/vlan 与内核/底层深度联动 |
| M30 | DNSMasq + ipset + base64 + 内核模块嵌入 | 待实施 | P0 | 深度嵌入并启用 dnsmasq ipset, base64 及必要内核模块 |
| M31 | 移除华硕反馈 (FRS) 功能 | 待实施 | P0 | 移除 FRS_FEEDBACK 反馈上报组件 |

---

## M01: 清理冗余文件

### 目标
移除源码树中与 TUF-BE3600 V2 无关的冗余文件。

### 待删除/精简的目录

#### M01.1 旧平台（MIPS）目录
```
release/src-rt/       # 旧式 MIPS/ARMv7 平台 (RT-AC68U等)
toolchain/           # MIPS 工具链 (HND平台不使用)
```

#### M01.2 无关机型的内核配置与 DTS
```
release/src-rt-5.04behnd.4916/targets/    # 仅保留 96764GW 目录
release/src-rt-5.04behnd.4916/kernel/dts/ # 仅保留 6764/ 目录
release/src-rt-5.04behnd.4916/targets/nvram/ # 仅保留 6764/ 目录
```

#### M01.3 无关机型的 rc/init.c 分支代码
通过 `#ifdef` 条件编译，确保 TUF-BE3600 V2 分支不受影响。

#### M01.4 不必要的软件组件
```
release/src/router/dropbear/             # 已被替换
release/src/router/lld2d/               # LLTD 已弃用
release/src/router/wtfast/              # 已停止服务
release/src/router/aaews/               # ASUS 账户引擎 (云控关闭后可移除编译)
```

#### M01.5 清理 Web UI 无用的 sysdep 覆盖
```
release/src/router/www/sysdep/          # 仅保留 TUF_UI 相关
```

### 实施步骤
1. 先用 `make TUF-BE3600_V2` 完成一次完整编译
2. 分批删除文件，每次验证编译
3. 确保最终编译产物与删除前功能一致

---

## M02: 解锁 rc_support 隐藏功能

### 目标
在 `release/src/router/rc/init.c` 约 20176-20191 行的 TUF-BE3600 V2 rc_support 初始化代码中，添加所有隐藏功能标志位。

### 当前 TUF-BE3600 V2 rc_support
```
mssid 2.4G 5G update usbX1 switchctrl manual_stb 11AX pwrctrl nandflash movistarTriple wifi2017 app ofdma wpa3
```

### 新增 rc_support 标志位

| 标志位 | 功能 | 控制文件 |
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
| `cloudcheck` | 云连接检查 | 后端 |
| `findasus` | ASUS 设备发现 | 后端 |
| `ssh` | SSH | UI |
| `snmp` | SNMP | UI |
| `ipv6` | IPv6 | UI |
| `ipv6pt` | IPv6 Pass-Through | UI |
| `v6option` | IPv6 选项 | UI |

### 实施位置
**文件**: `release/src/router/rc/init.c` (约 20176-20191 行，`TUFBE3600_V2` 分支)

---

## M03: WiFi 国家/区域/信道全解锁

### 目标
破除 TUF-BE3600 V2 (BCM6764) 固件中的 WiFi 国家码、区域限制、信道锁，实现全球可用全信道全功率。

### M03.1: ACS 信道优化
**文件**: `release/src/router/rc/sysdeps/init-broadcom.c`

- 默认 `acs_dfs=1` 启用 DFS 信道
- 默认 `acs_band3=1` 解锁 UNII-3 (149-165信道)
- 移除对 `territory_code` 的信道排除依赖
- ACS 信道排除列表最小化

### M03.2: Country Code 处理
**文件**: `release/src/router/rc/sysdeps/init-broadcom.c` (约 8055-8148)

修改 `init_syspara()` 中的 ccode 赋值逻辑，允许用户通过 Web UI 自由设置 `wl0/wl1_country_code`。

### M03.3: 添加 WiFi 国家码自定义 UI
**文件**: 修改或新建 Web 页面

新增 "Country Code Override" 选项：
- 预置国家码列表：US(全信道全功率), AU(全信道), TW, SG, CN, EU(DFS多) 等
- 手动输入 `wl0_country_code` / `wl1_country_code`
- 显示当前可用信道列表

### M03.4: BCM6764 WiFi 7/MLO 适配
**文件**: `release/src/router/shared/wlif_utils_ax.c` (约 3350行)

确认 TUF-BE3600 V2 的 MLO 配置为 `"1 0 -1 -1"` (2G + 5G MLO)，确保 MLO 功能正常。

---

## M04: WiFi 功率增强

### M04.1: 提升功率上限 (BCM6764)
**文件**: `release/src/router/shared/defaults.c` + `release/src/router/rc/init.c`

BCM6764 的功率控制通过 NVRAM 变量：
```
sb/1/maxp2ga0=0x64 (25dBm)
sb/1/maxp2ga1=0x64
pci/2/1/maxp5ga*=0x6A (26.5dBm)
wl_txpower=100
```

### M04.2: 关闭节能
```
sb/1/ed_thresh2g=-70      # 降低 ED 阈值（提高灵敏度）
sb/1/eu_edthresh2g=       # 清除 EU 特殊设置
wl0_radio_pwrsave=0
wl1_radio_pwrsave=0
wl0_mimo_pwrsave=0
wl1_mimo_pwrsave=0
```

### M04.3: 添加功率显示
首页面板显示当前功率 (dBm) + 最大功率 (dBm)

---

## M05: CPU 调度与温度管理

目标：基于 BCM6764 (ARM Cortex-A7) 启用 CPUFREQ，实现 CPU 温度降低的同时保持 WiFi 功率不变。

**已实施**：内核配置文件 `config_base.6a.6756` 已启用 CPUFREQ，但 BCM6764 的内核配置路径不同。

需要找到 BCM6764 的内核配置对应文件，同样启用 CPUFREQ。

---

## M06: 华硕云控总开关 ✓ (已实施)

### 新增 NVRAM 变量
```c
{ "asus_cloud_enable", "1" }
```

### 控制范围
- DDNS (asuscomm.com)
- AiCloud
- Cloud Sync
- Cloud Check
- 反馈上报 (FRS)
- AAE 通信
- ASUS Router App
- Let's Encrypt

### 实施位置
- `defaults.c` - NVRAM 默认值
- `shared/cloud_control.h` - 封装检查函数
- `init.c` - `init_nvram2()` 云控禁用时强制关闭各项服务
- `services.c` - `start_ddns()`, `start_cloudcheck()` 添加 gating
- `usb.c` - `start_cloudsync()` 添加 gating

---

## M07: 高级交换机控制 (RTL8372)

### M07.1: RTL8372 端口控制
TUF-BE3600 V2 使用 Realtek RTL8372 交换机芯片，控制方式与 BCM 不同：
- 通过 `rtkswitch` 模块控制
- `ethswctl` 命令的 RTL 变体
- VLAN 通过 vlan4094 实现扩展 WAN

### M07.2: 端口镜像
利用 RTL8372 内置端口镜像功能，Web UI 配置监控端口和被监控端口。

### M07.3: Flow Control / 端口速度
- 每端口独立流量控制
- 端口速度强制 (10/100/1000/2500M)

---

## M08: UPnP 带宽限速

### 目标
新增 UPnP 端口映射带宽限制功能，允许用户限制每个 UPnP 规则的最大上行/下行速率。

### NVRAM 新增变量
```c
{ "upnp_maxrate_enable", "0" },       // UPnP 限速总开关
{ "upnp_default_maxup", "0" },        // 默认最大上行 (Kbps, 0=不限)
{ "upnp_default_maxdown", "0" },      // 默认最大下行 (Kbps, 0=不限)
{ "upnp_maxrate_rules", "" },         // 按设备/协议的限速规则
```

### 实现方案

1. **miniupnpd 扩展**：在 `miniupnpd/upnpredirect.c` 中添加带宽参数处理
2. **iptables tc 联动**：当创建 UPnP 端口映射时，通过 TC 或 iptables `--connbytes` 添加带宽限制
3. **Web UI 新增页面**：`Advanced_UPnP_Content.asp` 新增限速配置

### 实现方式（选择）
- **方案 A**：修改 miniupnpd 源码，传递限速参数，结合 `tc` (traffic control) 实现
- **方案 B**：在防火墙层用 `iptables` + `tc filter` 对 UPnP 规则添加带宽限制

---

## M09: STUN 自定义

### 目标
允许用户自定义 STUN 服务器地址，自定义 STUN 检测接口，自定义检测间隔。

### NVRAM 新增变量
```c
{ "stun_server", "stun.l.google.com" },     // STUN 服务器
{ "stun_port", "19302" },                   // STUN 端口
{ "stun_interface", "" },                   // 指定接口 (默认自动)
{ "stun_interval", "300" },                 // 检测间隔秒数
{ "stun_keepalive", "1" },                  // Keep-Alive
```

### 修改点
- `rc/services.c` 中 `ministun` 调用参数改为 NVRAM 读取
- Web UI 新增 STUN 配置：`Advanced_WAN_Content.asp` 添加 STUN 自定义选项

---

## M10: FullCone NAT 防火墙模式

### 当前状态
FullCone NAT 已在内核 iptables NAT 扩展中支持 (`libxt_NAT.c`)，并且在 `firewall.c` 中已根据 `nat_type` NVRAM 选择 fullcone/symmetric。

### 需要做
1. **默认启用 FullCone**：`defaults.c` 中 `nat_type` 默认值改为 `1`
2. **rc_support 添加 fullcone 标志**：解锁 Web UI 中的 FullCone 开关
3. **确认 BCM6764 内核支持**：检查内核配置中 `CONFIG_NETFILTER_XT_NAT` 和 xt_NAT 模块是否已启用

### 实施位置
- `defaults.c`: `{ "nat_type", "1" }` (默认 FullCone)
- `init.c`: `add_rc_support("fullcone")`
- `www/Advanced_WAN_Content.asp`: 确认 NAT 类型选择 UI 可见

---

## M11: 移除网络神盾 (AiProtection / bwdpi)

### 目标
允许用户彻底移除 AiProtection / TrendMicro bwdpi 组件，释放系统资源。

### 实现方案

**方案一（推荐）**：NVRAM 开关禁用加载
```c
{ "disable_bwdpi", "0" }            // 0=正常 1=完全禁用 bwdpi
```
在 `rc/services.c` 的 `start_bwdpi_check()` 和 bwdpi 启动点添加检查。

**方案二**：编译时移除 bwdpi 模块
修改 Makefile 条件：`RTCONFIG_BWDIP=n` 等配置。

### 影响范围
- bwdpi (深度包检测)
- TrendMicro 引擎
- AiProtection 全部功能（智能网络卫士）
- 自适应 QoS (依赖 bwdpi)
- 流量分析 (依赖 bwdpi)

---

## M12: UU 加速器 AP 模式 + WOL 持久化

### 需求
在 AP 模式下，网易 UU 加速器和内置 WOL (Wake-On-LAN) 服务应持续运行。

### 当前问题
AP 模式下，路由器的 WAN 接口发生变化，UU 加速器的网络检测逻辑可能误判，WOL 服务可能被关闭。

### 修改点

1. **UU 启动逻辑** (`rc/ntp.c:87-88`): 在 AP 模式下同样保持 UU 进程运行
2. **WOL 服务**：检查 AP 模式下的 WOL 守护进程持久化逻辑
3. **网络状态相关**：AP 模式下的网络变化不触发 UU/WOL 停止

---

## M13: 首页面板增强

### 目标
在 Dashboard/首页 添加系统状态显示面板。

### 新增显示元素

| 元素 | 数据来源 | 实现方式 |
|------|---------|----------|
| CPU 温度 | `web.c` → `get_cpu_temperature()` (读取 `/sys/power/bpcm/cpu_temp`) | 已有 EJ 函数，添加到首页 |
| 2.4G 网卡温度 | `wl -i wl0 phy_tempsense` 或 sysfs | 新增 EJ 函数 |
| 5G 网卡温度 | `wl -i wl1 phy_tempsense` 或 sysfs | 新增 EJ 函数 |
| CPU 频率 | `/sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq` | 新增 EJ 函数 |
| 当前功率 | `wl -i wl0 txpwr` 或 `/proc/net/wl/txpwr` | 新增 EJ 函数 |
| 最大功率 | NVRAM `maxp2ga0`, `maxp5ga0` 等 | JS 读取 nvram + 计算 |

### 实现位置

- `httpd/web.c`: 新增 `get_wlan_temp()`, `get_cpu_freq()`, `get_tx_power()` EJ 处理函数
- `www/index_style.css`: 新增仪表盘样式
- `www/sysdep/FUNCTION/TUF_UI/index.asp`: 添加显示面板 HTML
- `www/state.js`: 添加温度/频率变量

---

## M14-M20

（基于此前 TUF-AX3000 V2 计划的 M09-M15，适配到 TUF-BE3600 V2）

---

## M21: 移除 ASD / AHS 组件

### 目标
移除 ASUS Support Diagnostic (ASD) 和 ASUS Heartbeat Service (AHS) 组件。

### ASD 组件
ASD 是华硕支持诊断服务，收集设备信息用于售后服务。

**移除方式**: 编译时 `ASD=n`

### AHS 组件
AHS 是华硕心率（心跳）服务，向华硕云持续上报设备运行状况。

**移除方式**: 编译时 `AHS=n`

### 实施位置
- `target.mak` TUF-BE3600_V2 行: 将 `ASD=y` 改为 `ASD=n`, `AHS=y` 改为 `AHS=n`
- `services.c`: 移除 ASD/AHS 启动调用 (如果触发)
- `init.c`: 清理 ASD/AHS 初始化代码

---

## M22: 更新 curl 组件

### 目标
将系统内置 curl 更新到最新稳定版以修复安全漏洞和提升 TLS 支持。

### 实施方式
- 更新 `release/src/router/curl/` 下的源码（当前版本可能为 7.x）
- 更新 `Makefile` 版本号
- 确认编译通过后链接 httpd 等组件

### 关键点
- 保持与现有 httpd 的 API 兼容
- 保留 HTTPS/SSL 支持

---

## M23: 移除 AWS IoT 智能家居

### 目标
移除华硕固件中亚马逊 AWS IoT 智能家居集成组件。

### 移除方式
检查并移除以下配置标志：
- `ACL96=y` → `ACL96=n` (Amazon Alexa Connect Kit)
- `GOOGLE_ASST=y` → `GOOGLE_ASST=n` (Google Assistant)
- `ALEXA=y` → `ALEXA=n` (Amazon Alexa)

### 实施位置
- `target.mak` TUF-BE3600_V2 行: 修改上述配置为 `n`
- 清理相关 Web UI 页面引用
- 清理 init.c / services.c / defaults.c 中的相关代码

---

## M24: 禁用自动更新 / 更新检测

### 目标
禁用固件自动更新和更新检测功能，避免系统回退或自动覆盖魔改固件。

### 实施方式
- `FORCE_AUTO_UPGRADE=y` → `FORCE_AUTO_UPGRADE=n` (强制自动升级)
- `FRS_LIVE_UPDATE=y` → `FRS_LIVE_UPDATE=n` (在线更新检测)
- `DOWNGRADE_CHECK=y` → `DOWNGRADE_CHECK=n` (降级检查)
- `FRS_FEEDBACK=y` → `FRS_FEEDBACK=n` (反馈功能，同步在 M31 实施)
- Web UI 层面禁止更新检测页面

### 实施位置
- `target.mak` TUF-BE3600_V2 行
- Web UI 更新页面可保留手动刷入，但移除自动检测

---

## M25: 优化后台字体

### 目标
优化 Web 管理后台的中英文字体显示效果。

### 实施方式
- 修改 `www/index_style.css` 或各主题 CSS
- 优化字体栈：优先系统原生字体 (如微软雅黑, PingFang SC, Noto Sans SC)
- 调整字体大小、行高、字距
- 确保 TUF_UI 主题下字体风格一致

### 实施位置
- `www/sysdep/FUNCTION/TUF_UI/` 下的 CSS 文件
- `www/index_style.css`

---

## M26: 开放管理界面 (LAN + WAN)

### 目标
管理界面默认对 LAN 和 WAN 均开放，方便远程管理。

### 实施方式
- NVRAM 默认: `http_lanport=80`, `http_wanport=8080`
- NVRAM 默认: `misc_http_x=1` (允许 WAN 访问 Web)
- NVRAM 默认: `http_enable=1`, `https_enable=1`
- 防火墙默认开放 WAN 端口

### NVRAM 新增/修改
| 变量名 | 旧值 | 新值 | 说明 |
|--------|------|------|------|
| misc_http_x | 0 | 1 | 允许 WAN 访问 Web |
| http_wanport | （未设置） | 8080 | WAN 侧 HTTP 端口 |

### 实施位置
- `defaults.c` - NVRAM 默认值修改
- `httpd/httpd.c` - 绑定监听 0.0.0.0 (所有接口)

---

## M27: AiMesh 节点 IP 管理

### 目标
AiMesh 模式下，支持使用 AiMesh 节点 IP 地址访问 Web 管理后台。

### 实施方式
- 检测当前是否为 AiMesh 节点模式
- 节点模式下启用 Web 管理服务并绑定节点 IP
- 放行 AiMesh 相关防火墙规则

### 实施位置
- `rc/services.c` - start_httpd 启动时检测节点模式
- `firewall.c` - 添加 AiMesh 节点 Web 访问规则

---

## M28: AP 模式 IP 访问 + 手机 App 发现

### 目标
AP 模式下：
1. 仍然支持通过 IP 地址直接访问路由器 Web 管理后台
2. 允许 ASUS Router App 等手机 App 在局域网中搜索到此路由器
3. 管理域名通过主路由 hosts 劫持至此路由器 IP

### 实施方式

#### M28.1: AP 模式 IP 访问
- 修改 AP 模式登录重定向逻辑，优先使用 IP 访问而非域名跳转
- 确保 httpd 在 AP 模式下持续监听所有接口

#### M28.2: 手机 App 发现
- 保持 LAN 侧 mDNS/Bonjour 服务启用
- NVRAM: `lan_ipaddr` 保持主路由分配的 IP
- ASUS Router App 通过 UDP 9999 发现，确保 AP 模式下端口开放

#### M28.3: 域名劫持支持
- 管理域名通过主路由 hosts/dnsmasq 解析到此路由器 IP
- Web 服务器支持虚拟主机访问

### 实施位置
- `rc/init.c` - AP 模式初始化逻辑
- `httpd/httpd.c` - 监听绑定
- `rc/services.c` - mDNS / App 发现服务

---

## M29: 三插件深度内核联动

### 目标
将 cpupower、multiwand、vlan 三个插件深度嵌入固件，与系统内核和底层直接联动调用（非 skipd/dbus 外壳方式）。

### 插件改造要点

#### M29.1: cpupower
- 当前使用 `dbus` / skipd 存储配置 → **改为 NVRAM 存储**
- 当前通过 `/koolshare/scripts/` 启动 → **改为 RC 服务 (init.d)**
- 当前频率操作通过 echo sysfs → **保留 sysfs 操作，增加 NVRAM 读写**
- Web UI 从 `/_api/cpupower` 改为 **原生 EJ 路由**

#### M29.2: multiwand
- 当前使用 `dbus` / skipd 存储配置 → **改为 NVRAM 存储**
- PPPoE/DHCP 拨号逻辑 → **集成到 rc/services.c 多WAN管理**
- 策略路由和 NAT 规则 → **集成到 rc/firewall.c**
- Web UI 改为 **`Advanced_MultiWAN_Content.asp`**

#### M29.3: vlan
- 当前使用 `dbus` / skipd 存储配置 → **改为 NVRAM 存储**
- VLAN 创建逻辑 → **修改 `rc/sysdeps/init-broadcom.c`**
- 端口聚合 (bond) → **集成到内核模块加载**
- Web UI 改为 **`Advanced_VLAN_Content.asp`**

### 关键技术点
- 移除对 `skipd` / `dbus` 的依赖
- 配置数据从 dbus 迁移到 NVRAM
- ASP 页面通过 `call` 方式调用后端 (writerc / restart)
- 系统 init.d 路由启用启动脚本

---

## M30: DNSMasq + ipset + base64 + 内核模块嵌入

### M30.1: DNSMasq + ipset
- 启用 dnsmasq ipset 支持（`ipset=/domain.com/ipset_name`）
- 适用于基于域名的流量分流（VPN/策略路由/广告过滤）
- 内核确认 `CONFIG_IP_SET` 已启用

### M30.2: Base64 支持
- 确保内核或 busybox 内置 base64 编解码工具
- 适用于脚本中的编码需求

### M30.3: 必要内核模块
检查并启用以下内核模块/功能：
```
CONFIG_NETFILTER_XT_SET=y        # ipset netfilter 支持
CONFIG_IP_SET=y                   # ipset 核心
CONFIG_IP_SET_HASH_NET=y          # ipset hash:net
CONFIG_IP_SET_HASH_IP=y           # ipset hash:ip
CONFIG_IP_VS=y                    # 可选 (IPVS)
CONFIG_TUN=y                       # TUN 设备 (VPN)
CONFIG_BRIDGE=y                    # 桥接 (VLAN)
CONFIG_VLAN_8021Q=y               # 802.1Q VLAN
CONFIG_BONDING=y                   # 端口聚合
CONFIG_CRYPTO_SHA256=y            # 加密模块
CONFIG_CRYPTO_SHA1=y
CONFIG_CRYPTO_MD5=y
CONFIG_CRYPTO_AES=y
CONFIG_CRYPTO_CBC=y
```

### 实施位置
- `config_base.6a.6764` - 内核配置启用上述模块
- `dnsmasq` 配置集成到 `/etc/dnsmasq.conf`
- `busybox` 确认 base64 applet 已启用

---

## M31: 移除华硕反馈 (FRS) 功能

### 目标
彻底移除华硕固件中的反馈上报 (FRS_FEEDBACK) 功能。

### 实施方式
- `FRS_FEEDBACK=y` → `FRS_FEEDBACK=n`
- 移除相关 Web UI 反馈入口
- 清理 `init.c` + `services.c` 中 FRS 启动代码
- 删除 `aaews` (ASUS账户引擎) 编译依赖

### 实施位置
- `target.mak` TUF-BE3600_V2 行
- `rc/services.c` / `rc/init.c`
- Web UI 页面清理

---

## 整合实施顺序

1. **M01** 清理冗余文件
2. **M06** 云控总开关 ✓ (已完成)
3. **M21** 移除 ASD/AHS + **M31** 移除 FRS 反馈
4. **M23** 移除 AWS IoT (ALEXA/ACL96/GOOGLE_ASST)
5. **M24** 禁用自动更新/更新检测 (FORCE_AUTO_UPGRADE/DOWNGRADE_CHECK/FRS_LIVE_UPDATE)
6. **M22** 更新 curl 组件
7. **M25** 优化后台字体
8. **M02** 解锁 rc_support (适配 TUF-BE3600 V2)
9. **M26** 开放管理界面 (LAN+WAN)
10. **M10** FullCone NAT + M08 UPnP + M09 STUN
11. **M03 + M04** WiFi 解锁 + 功率增强 (BCM6764)
12. **M05** CPU 调度管理 (BCM6764 内核配置) + **M30** 内核模块嵌入
13. **M07** 交换机控制 (RTL8372)
14. **M11** 移除网络神盾
15. **M12** UU + WOL AP 模式 + **M28** AP 模式 IP 访问
16. **M27** AiMesh 节点 IP 管理
17. **M13** 首页面板增强
18. **M29** 三插件深度内核联动 (cpupower/multiwand/vlan)
19. **M15-M20** 剩余功能
