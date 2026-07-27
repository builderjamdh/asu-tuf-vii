# ASUS TUF-BE3600 V2 固件编译 — AI 交接文档

## 项目概述
- 源码：ASUS GPL 发布包 `GPL_TUF-3600_V2_3.0.0.6.102.39099-gd8de8b3_1283-ge738b_BB0C.tgz`
- 仓库：`https://github.com/builderjamdh/asu-tuf-vii` (branch: `main`)
- CI：GitHub Actions，self-hosted Debian runner（16 核），超时 480 分钟
- 目标：编译出 TUF-BE3600_V2 的 `.trx` 固件

## 编译命令
```bash
cd release/src-rt-5.04behnd.4916
make TUF-BE3600_V2
```
顶层 Makefile 映射 `TUF-BE3600_V2` → `bin` → 内核 + 用户空间 → 固件镜像。

## 工具链
- 路径：`/opt/toolchains/crosstools-arm_softfp-gcc-10.3-linux-4.19-glibc-2.32-binutils-2.36.1`
- 部署：workflow 从 `https://github.com/SWRT-dev/bcmhnd-toolchains.git` 拉取
- 还有两套辅助工具链（armtf 硬浮点、aarch64 optee），同仓库获取

## 当前状态（commit `ad4ed3f00`）
- 内核模块编译 ✅
- 用户空间编译进行中
- **904 个 autotools configure 错误**——全部是 "CFLAGS has changed since the previous run"
- **没有 `.trx` 生成**

## 已修改的关键文件

### `.github/workflows/build.yml` — CI 流程（多次修改）
- 两阶段构建：`-j16` 配置 → 清理 autotools 缓存 → `-j24` 编译
- `NOCONFIGURE=1`：阻止 autoreconf 内部跑 configure
- `LD_LIBRARY_PATH` + `TOOLCHAIN_BASE`：官方 README 要求
- PATH 劫持：`/tmp/wrapper-bin/gcc`（GCC 14 兼容）+ `/tmp/ccache-bin/`（ccache）
- CONFIG_SITE：50+ autotools 缓存变量（交叉编译跳过运行时检测）
- json-c 头文件预生成 + stamp-h1 伪造（绕过 configure 失败）

### `release/src-rt/platform.mak` — 第 82 行
```
export CONFIGURE := ./configure --disable-option-checking LD=...ld --host=...
```
**最新修改**：在 CONFIGURE 定义中直接加入 `--disable-option-checking`，
试图从源头消除所有 autotools 包的 "CFLAGS has changed" 环境检测错误。

### `release/src-rt/Makefile` — 第 1533-1535、4108-4109 行
禁用了 `RTCONFIG_AWSIOT=y`（之前硬编码强制启用 aws-iot → 依赖 json-c → configure 失败阻断整个构建）。

## 已知问题及修复

| 问题 | 修复 | 状态 |
|------|------|------|
| GCC 14 把 `main(){}` 当 error | `/tmp/wrapper-bin/gcc` PATH 劫持加 `-Wno-implicit-int` | ✅ |
| `bcm96764/config_base` 找不到 | `rm -rf` 后 `ln -sf` | ✅ |
| 并行编译竞态 | 两阶段：`-j16` 配置 → `-j24` 编译 | ✅ |
| `bcm_thermal.ko` 符号未定义 | 移除 CPUFREQ sed hack | ✅ |
| `usbmuxd` 链接失败 | 缺 `libusbmuxd-2.0`，`-k` 跳过 | ⚬ 非致命 |
| aws-iot → json-c 编译失败 | Makefile 禁 aws-iot + json-c 头预生成 | ✅ |
| 904 个 autotools configure 错误 | platform.mak 加 `--disable-option-checking` | 🔧 等验证 |
| db-4.8.30 errno 未定义 | glibc 2.32 兼容性 | ⚬ 非致命（-k 跳过） |
| `version.h` / `zlib.h` 缺失 | 并行编译竞态，两阶段规避 | ⚬ |

## 构建流程概要
1. Checkout → Install Deps（apt + git-lfs）→ Verify（文件/符号链接完整性）
2. Cache/Deploy 工具链 → Configure Git → Version Tags
3. 权限修复 → Build：
   - 预清理 autotools 状态（`find release -name config.status -delete`）
   - 预生成 json-c 头文件 + stamp-h1
   - 两阶段：`make -j16 -k` → 清理 autotools 缓存 → `make -j24 -k`
4. Validate Firmware → Collect Artifacts

## 关键目录
- `release/src-rt-5.04behnd.4916/` — Broadcom HND 5.04 SDK（构建根目录）
- `release/src-rt/Makefile` — 顶层构建入口（`TUF-BE3600_V2` → `bin`）
- `release/src-rt/platform.mak` — 预编译文件分发 + CONFIGURE 定义
- `release/src/router/` — 用户空间包（busybox/httpd/openssl 等）
- `release/src-rt-5.04behnd.4916/router-sysdep/` — Broadcom 用户空间 Makefile
- `release/src-rt-5.04behnd.4916/router-sysdep/hnd_extra/prebuilt/` — 6 个核心预编译 .o
- `release/src/router/hnd_extra/prebuilt/` — 22 个通用预编译 .o
- `release/src-rt-5.04behnd.4916/targets/96764GW/96764GW.TUF-BE3600_V2` — 目标配置

## 如果 904 个 configure 错误仍然存在
说明 `--disable-option-checking` 对某些 autoconf 版本无效（2.61 之前不支持）。
备选方案：
1. 找出哪些包不支持此 flag，只对那些包单独处理
2. 或者直接预生成所有包的 config.h（类似 json-c 的做法）
3. 或者用 `make -j1` 串行构建避开竞态

## 其他注意事项
- Self-hosted runner 上 `/opt/ccache` 持久化，ccache 用 PATH 劫持方式（`common.mak` 会覆盖 `CC` 环境变量）
- `$SRCDIR/build.log` 只包含 make 输出（通过 `tee`），不包含 workflow echo 命令
- 官方 README 在 `/tmp/tarball_readmes/asuswrt/README.TXT`
