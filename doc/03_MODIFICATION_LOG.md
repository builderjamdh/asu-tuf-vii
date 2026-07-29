# ASUS TUF-BE3600 V2 魔改固件 - 修改日志

---

## 日志格式说明

每条修改记录包含：

```
## [YYYY-MM-DD] [模块编号] 修改标题

**修改类型**: 新增 / 修改 / 删除 / 修复

**涉及文件**:
- `文件路径1` (行号范围)
- `文件路径2` (行号范围)

**核心逻辑**:
详细描述修改的目的和实现原理

**NVRAM 变更** (如有):
| 变量名 | 旧值 | 新值 | 说明 |

**验证方法**:
如何确认修改生效的命令或步骤
```

---

## 修改记录

### [2026-07-18] M01.0 初始化文档

**修改类型**: 新增

**涉及文件**:
- `doc/00_OVERVIEW.md` (新建后重写)
- `doc/01_BUILD_GUIDE.md` (新建)
- `doc/02_MODIFICATION_PLAN.md` (新建后重写)
- `doc/03_MODIFICATION_LOG.md` (当前文件, 新建)

**核心逻辑**:
创建文档体系，基于 TUF-BE3600 V2 (BCM6764, WiFi 7) 整理项目结构、编译指引、修改计划。

---

### [2026-07-18] M06.0 云控总开关 - 新增 NVRAM + Headers

**修改类型**: 新增 / 修改

**涉及文件**:
- `release/src/router/shared/defaults.c` (3431行附近)
- `release/src/router/shared/cloud_control.h` (新建)

**核心逻辑**:
添加 `asus_cloud_enable` NVRAM 变量（默认1=启用云服务），创建 cloud_control.h 提供 `cloud_disabled()` 和 `cloud_enabled()` 封装检查函数。

**NVRAM 变更**:
| 变量名 | 默认值 | 说明 |
|--------|--------|------|
| asus_cloud_enable | 1 | 华硕云控总开关 (1=启用, 0=禁用) |

---

### [2026-07-18] M06.1 云控总开关 - 启动时禁用所有云服务

**修改类型**: 修改

**涉及文件**:
- `release/src/router/rc/init.c` (24192行附近)

**核心逻辑**:
在 `init_nvram2()` 中，当 `asus_cloud_enable=0` 时，强制关闭 DDNS、CloudSync、CloudCheck、反馈、WebDAV、FindASUS、WPS，清除已注册的 ASUS DDNS 信息，并提交 NVRAM。

---

### [2026-07-18] M06.2 云控总开关 - 服务启动 gating

**修改类型**: 修改

**涉及文件**:
- `release/src/router/rc/services.c` (start_ddns, start_cloudcheck)
- `release/src/router/rc/usb.c` (start_cloudsync)

**核心逻辑**:
在 DDNS 更新入口、CloudCheck 启动、CloudSync 启动处添加 `asus_cloud_enable=0` 检测，跳过云服务。

---

### [2026-07-18] 模型修正

**修改类型**: 修正

**涉及文件**:
- `doc/00_OVERVIEW.md` (重写)
- `doc/02_MODIFICATION_PLAN.md` (重写)

**核心逻辑**:
型号TUF-BE3600 V2 (BCM6764, WiFi 7)。
交换机芯片由 BCM53134 修正为 Realtek RTL8372。

---

### [2026-07-18] M02.1 rc_support 解锁 (TUF-BE3600 V2)

**修改类型**: 修改

**涉及文件**:
- `release/src/router/rc/init.c` (20054行 TUF-BE3600 V2 / RTBE58U 分支)

**核心逻辑**:
在 TUF-BE3600 V2 分支 (MODEL_RTBE58U_V2/RTBE58U/RTBE55) 添加完整 rc_support 标志：tagged_based_vlan, mtlancfg, vlan, lacp, dfs, wifi7, mumimo, smart_connect, reboot_schedule, dnsfilter, traffic_analyzer, dblog, dhdlog, email, nt_center, fullcone, getrealip, cloudcheck, ssh, snmp, ipv6, reboot_schedule, qr_code, omega, etc.

---

### [2026-07-18] M03/M04 WiFi 解锁默认值

**修改类型**: 修改

**涉及文件**:
- `release/src/router/shared/defaults.c`

**核心逻辑**:
设置 `acs_dfs=1`, `acs_band3=1`, radio_pwrsave=0, 清除 EU ED 阈值限制，解除 WiFi 7 功能锁定。

---

### [2026-07-18] M05.0 CPUFREQ 内核配置

**修改类型**: 修改

**涉及文件**:
- `release/src-rt-5.04behnd.4916/kernel/linux-4.19/config_base.6a.6764`
- `release/src-rt-5.04behnd.4916/kernel/linux-4.19/config_base.6a.6764L`
- `release/src-rt-5.04behnd.4916/kernel/linux-4.19/config_base.6a.6756`

**核心逻辑**:
启用 CPUFREQ 及所有调速器 (performance/powersave/ondemand/conservative/schedutil) 为 `=y`。禁用 GENERIC_CPUFREQ_DRIVER。启用 MENU/LADDER CPU idle governor。BCM6764 和 BCM6756 配置均已修改。

---

### [2026-07-18] M10.0 FullCone NAT 默认启用

**修改类型**: 修改

**涉及文件**:
- `release/src/router/shared/defaults.c`

**核心逻辑**:
`nat_type` 默认值从 `0` 改为 `1` (FullCone NAT 启用)。

---

### [2026-07-18] M11.0 Network Shield / BWDPI 移除

**修改类型**: 修改

**涉及文件**:
- `release/src/router/rc/services.c` (start_bwdpi 入口)
- `release/src-rt/target.mak` (行151)

**核心逻辑**:
services.c 中 bwdpi 启动添加 `disable_bwdpi` NVRAM 检测。target.mak TUF-BE3600_V2 构建标志设置 `BWDPI=n`。

---

### [2026-07-18] M13.0 Dashboard EJ 扩展函数

**修改类型**: 新增

**涉及文件**:
- `release/src/router/httpd/web.c` (7827-7948行, 42110行 hooks)

**核心逻辑**:
新增 EJ 函数 `get_wlan_temp()`, `get_cpu_freq()`, `get_tx_power()`, `get_max_tx_power()`，并在 EjHooks 数组中注册。Dashboard 可显示 WiFi 温度、CPU 频率、发射功率、最大功率。

---

### [2026-07-18] M21.0 移除 ASD/AHS 组件

**修改类型**: 修改

**涉及文件**:
- `release/src-rt/target.mak` (行151)

**核心逻辑**:
target.mak TUF-BE3600_V2 构建标志设置 `ASD=n AHS=n`。

---

### [2026-07-18] M23.0 移除 AWS IoT 智能家居

**修改类型**: 修改

**涉及文件**:
- `release/src-rt/target.mak` (行151)

**核心逻辑**:
target.mak TUF-BE3600_V2 构建标志设置 `ACL96=n GOOGLE_ASST=n ALEXA=n`。

---

### [2026-07-18] M24.0 禁用自动更新

**修改类型**: 修改

**涉及文件**:
- `release/src-rt/target.mak` (行151)

**核心逻辑**:
target.mak TUF-BE3600_V2 构建标志设置 `FORCE_AUTO_UPGRADE=n FRS_LIVE_UPDATE=n DOWNGRADE_CHECK=n`。

---

### [2026-07-18] M25.0 Web UI 字体优化

**修改类型**: 修改

**涉及文件**:
- `release/src/router/www/sysdep/FUNCTION/TUF_UI/index_style.css`

**核心逻辑**:
CSS 字体栈更新为 `Microsoft YaHei, PingFang SC, Noto Sans SC`，支持现代中文字体渲染。

---

### [2026-07-18] M26.0 开放管理界面 (LAN+WAN)

**修改类型**: 修改

**涉及文件**:
- `release/src/router/shared/defaults.c`
- `release/src/router/rc/init.c` (20054行附近)

**核心逻辑**:
defaults.c: `misc_http_x` 默认值改为 `1` (启用), `http_wanport` 默认值改为 `8080`。
init.c: TUF-BE3600 V2 block 设置 `misc_http_x=1`, `misc_httpport_x=8080`。

---

### [2026-07-18] M27.0 AiMesh 节点 IP 管理

**修改类型**: 新增

**涉及文件**:
- `release/src/router/rc/init.c` (20054行附近)

**核心逻辑**:
在 TUF-BE3600 V2 block 添加 AiMesh 节点 IP 管理 NVRAM 默认值。

---

### [2026-07-18] M28.0 AP 模式 IP 访问 + App 发现

**修改类型**: 修改

**涉及文件**:
- `release/src/router/shared/defaults.c`
- `release/src/router/rc/init.c`
- `release/src/router/rc/services.c` (start_httpd)

**核心逻辑**:
defaults.c: `ap_mgmt_mode=1`, `ap_smartdiscover=1`。
init.c: TUF-BE3600 V2 block 设置 AP 管理 NVRAM。
services.c: AP 模式下在 WAN 端口 8080 启动额外 httpd 实例，保持 IP 管理可达。

---

### [2026-07-18] M29.0 三插件深度内核联动

**修改类型**: 新增

**涉及文件**:
- `release/src/router/httpd/web.c` (EJ 函数 + hooks 注册)
- `release/src/router/rc/cpupower.sh` (新建)
- `release/src/router/rc/multiwand.sh` (新建)
- `release/src/router/rc/vlan_mgr.sh` (新建)
- `release/src/router/www/Advanced_CPUPOWER_Content.asp` (新建)
- `release/src/router/www/Advanced_MULTIWAN_Content.asp` (新建)
- `release/src/router/www/Advanced_VLAN_MGR_Content.asp` (新建)
- `release/src/router/rc/services.c` (插件启动 hooks)
- `release/src/router/www/require/menuTrees/menuTree_TUF.js` (菜单注册)

**核心逻辑**:
- web.c: 新增 `get_cpupower_status()`, `get_multiwand_status()`, `get_vlan_status()` EJ 函数
- cpupower.sh: 读取 NVRAM, 写入 sysfs cpufreq/ondemand 参数
- multiwand.sh: PPPoE/DHCP/static 多 WAN NAT/routing
- vlan_mgr.sh: 802.1Q VLAN + 桥接创建
- services.c: 在 cloudcheck 之后启动插件
- menuTree_TUF.js: Alexa/IFTTT 替换为 CPU调度控制/多WAN管理/VLAN管理; 反馈菜单移除

---

### [2026-07-18] M30.0 DNSMasq ipset + 内核模块

**修改类型**: 修改

**涉及文件**:
- `release/src-rt-5.04behnd.4916/kernel/linux-4.19/config_base.6a.6764`

**核心逻辑**:
启用 `CONFIG_IP_SET=y` 及 hash_ip/net/ipport/ipportip/list_set 子模块。启用 `CONFIG_BONDING=y` (从 =m 改为 =y)。VLAN_8021Q 和 crypto 模块已默认启用。

---

### [2026-07-18] M31.0 移除 FRS 反馈功能

**修改类型**: 修改

**涉及文件**:
- `release/src-rt/target.mak` (行151)
- `release/src/router/rc/init.c` (frs_feedback 条件编译)

**核心逻辑**:
target.mak: `FRS_FEEDBACK=n COMFW=n`。init.c: frs_feedback 代码通过条件编译移除。

---

### [2026-07-18] M12.0 UU/WOL AP 模式持久化

**修改类型**: 修改

**涉及文件**:
- `release/src/router/rc/ntp.c`

**核心逻辑**:
UU 插件 exec 调用不再受 AP 模式限制，确保 AP 模式下 UU 加速器和 WOL 持续运行。

---

### [2026-07-18] M08/M09 UPnP 限速 + STUN 自定义

**修改类型**: 新增

**涉及文件**:
- `release/src/router/shared/defaults.c`
- `release/src/router/rc/init.c`

**核心逻辑**:
defaults.c: `upnp_maxrate_enable=0`, `upnp_default_maxup/down`, `upnp_maxrate_rules`。`stun_server`, `stun_port`, `stun_interface`, `stun_interval`, `stun_keepalive` NVRAM 默认值。
init.c: TUF-BE3600 V2 block 设置默认值。

---

### [2026-07-18] GitHub Actions CI/CD 工作流

**修改类型**: 新增 (文档)

**涉及文件**:
- `doc/01_BUILD_GUIDE.md` (§7 GitHub Actions workflow)

**核心逻辑**:
完整的 build.yml 工作流：self-hosted runner, 编译, artifact 上传, tag 自动发版。

---

### [2026-07-18] rogsoft/koolcenter 集成分析

**修改类型**: 分析 (决策)

**核心逻辑**:
完整分析了 rogsoft/koolcenter/softcenter 框架架构（httpdb, perp, skipd, dbus 系统）。
**决策：不集成完整 softcenter 框架**。原因：skipd 是 Merlin 专有组件，我们的固件基于原厂 ASUS，不包含 skipd。三插件 (cpupower/multiwand/vlan) 已通过原生 NVRAM + RC 脚本 + EJ 函数实现深度内核联动，无需 softcenter 基础设施。

---

### [2026-07-18] wifiboost 插件逆向分析

**修改类型**: 分析

**涉及文件**:
- `tools/deobfuscate_wifiboost.py` (新建)
- `tools/analyze_packer.py` (新建)

**核心逻辑**:
分析 rogsoft/wifiboost 插件。发现：
1. `install.sh`, `wifiboost_config.sh`, `wifiboost_status.sh` 均为 SHC 编译的 ARM ELF 二进制（非明文 shell 脚本）
2. 使用 ptrace 反调试 + /proc/self/as 读自身内存 + 强加密（熵 7.96/8.0 bits/byte）
3. Web 界面 (Module_wifiboost.asp) 暴露完整逻辑：修改 NVRAM `maxp2ga0`/`maxp5gb0a0` 值，自动切换澳大利亚区域
4. **付费 DRM 系统**：联系外部服务器 `42.192.18.234:8083`，需激活码
5. **安全风险**：向外部服务器发送机器码，存在信息泄露风险
6. TUF-BE3600 V2 显式支持（读取 `sb/1/maxp2ga0` 和 `sb/0/maxp5gb0a0`）
7. 静态解密不可行，需 ARM 运行时环境或 QEMU 模拟 + strace
8. **结论**：我们的 cpupower.sh 已覆盖相同功能（NVRAM 写入功率值），无需引入带 DRM 和外联的第三方付费插件

---

## M32 - koolcenter 缺失内核依赖补全 (kernel config)

**日期**: 2026-07-19

**修改类型**: 内核配置修改

**涉及文件**:
- `release/src-rt-5.04behnd.4916/kernel/linux-4.19/config_base.6a.6764`

**核心逻辑**:
补全 koolcenter 软件中心所需内核依赖：
1. `CONFIG_TCP_CONG_BBR=y` — BBR TCP 拥塞控制算法
2. `CONFIG_DEFAULT_TCP_CONG="bbr"` — 默认使用 BBR
3. `CONFIG_NET_SCH_FQ=y` — Fair Queue 调度器（BBR 推荐搭配）
4. `CONFIG_NF_FLOW_TABLE=y` — 网络流量表硬件卸载
5. `CONFIG_MACVLAN=y` — MACVLAN 虚拟网卡（Docker/VPN 插件依赖）
6. `CONFIG_VETH=y` — 虚拟以太网对（容器网络依赖）
7. `CONFIG_BRIDGE_IGMP_SNOOPING=y` — 桥接 IGMP 嗅探（组播优化）
8. `CONFIG_BRIDGE_VLAN_FILTERING=y` — 桥接 VLAN 过滤
9. `CONFIG_IP_NF_TARGET_TTL=y` — TTL 修改 target（iptables）
10. `CONFIG_NETFILTER_XT_TARGET_CHECKSUM=y` — 校验和 target
11. `CONFIG_NETFILTER_XT_MATCH_SET=y` — ipset 匹配模块
12. `CONFIG_NETFILTER_XT_TARGET_SET=y` — ipset target 模块
13. `CONFIG_NF_REJECT_IPV6=y` — IPv6 REJECT target
14. 移除重复的 `# CONFIG_IP_SET is not set` 行

---

## M33 - BBR TCP 加速 + 状态显示

**日期**: 2026-07-19

**修改类型**: 功能新增

**涉及文件**:
- `release/src-rt-5.04behnd.4916/kernel/linux-4.19/config_base.6a.6764` (见 M32)
- `release/src/router/shared/defaults.c` — BBR NVRAM 默认值
- `release/src/router/rc/init.c` — 
  - TUF-BE3600_V2 块内添加 BBR 默认设置
  - sysctl init 段内运行时应用 BBR（f_write_string /proc/sys/...）
- `release/src/router/httpd/web.c` — `get_bbr_status()` EJ 函数 + 注册

**核心逻辑**:
1. 内核已启用 BBR (M32)，默认 `tcp_congestion_control=bbr`
2. NVRAM 控制开关：`bbr_enable` (默认 1)、`bbr_congestion` (bbr)、`bbr_qdisc` (fq)
3. 启动时通过 `f_write_string()` 写入 `/proc/sys/net/core/default_qdisc` 和 `/proc/sys/net/ipv4/tcp_congestion_control`
4. Dashboard EJ 函数 `get_bbr_status()` 返回 JSON：拥塞算法、qdisc、当前连接数、启用状态
5. 防火墙自定义规则页面 `Advanced_FBCUSTOM_Content.asp` 中集成 BBR 状态显示

---

## M34 - AP 模式 WAN 端口硬件转发优化

**日期**: 2026-07-19

**修改类型**: 功能优化

**涉及文件**:
- `release/src/router/shared/defaults.c` — `ap_wan_hwaccel`、`ap_wan_fc_disable` NVRAM
- `release/src/router/rc/init.c` — TUF-BE3600_V2 块内 AP 模式 fc 强制开启逻辑

**核心逻辑**:
1. 新 NVRAM: `ap_wan_hwaccel` (默认 1)、`ap_wan_fc_disable` (默认 0)
2. 当 AP 模式 + `ap_wan_hwaccel=1` 时：
   - 强制 `fc_disable=0`（流缓存不关闭）
   - 启用 `bridge-nf-call-iptables=1`（桥接层 iptables 透传）
3. BCM flow cache (`BCM_PKTFLOW=m`) 在 AP 模式下保持启用，优化 WAN→LAN 桥接转发性能
4. 现有 `hnd_nat_ac_init()` 已通过 `fc enable` + `runner enable` 处理路由模式加速，AP 模式下额外确保桥接硬件转发

---

## M35 - 防火墙自定义规则管理

**日期**: 2026-07-19

**修改类型**: 功能新增

**涉及文件**:
- `release/src/router/shared/defaults.c` — `fb_custom_enable`、`fb_ipv4_rules`、`fb_ipv6_rules` NVRAM
- `release/src/router/rc/fb_custom.sh` (新建) — 防火墙规则管理 RC 脚本
- `release/src/router/rc/services.c` — `notify_rc` 中 `start_firewall` 后 hook `fb_custom.sh start`
- `release/src/router/www/Advanced_FBCUSTOM_Content.asp` (新建) — Web 管理界面
- `release/src/router/www/require/menuTrees/menuTree_TUF.js` — 菜单注册
- `release/src/router/rc/init.c` — TUF-BE3600_V2 块内默认关闭

**核心逻辑**:
1. NVRAM 存储自定义 IPv4/IPv6 规则 (`fb_ipv4_rules`、`fb_ipv6_rules`)，每行一条 iptables/ip6tables 规则
2. `fb_custom.sh`：从 NVRAM 读取规则 → 写入临时文件 → 创建 `FB_CUSTOM`/`FB_CUSTOM6` 链 → 插入 INPUT/FORWARD
3. 支持直接 eval 执行 `iptables -I ...` 格式或默认注入
4. 以 `#` 开头的行为注释跳过
5. Web 界面提供文本框编辑，支持 BBR 状态显示
6. 默认关闭 (`fb_custom_enable=0`)，需手动启用
7. `notify_rc("firewall") → start_firewall() → eval("fb_custom.sh", "start")` 确保每次防火墙重建后规则重新生效

