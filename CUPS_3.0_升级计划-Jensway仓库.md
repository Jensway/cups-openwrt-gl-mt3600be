# Jensway 仓库升级至 CUPS 3.0 计划

## 一、现状与目标

| 项目 | 当前 (2.4.16) | 目标 (3.0) |
|------|---------------|-------------|
| 仓库 | [Jensway/cups-openwrt-gl-mt3600BE](https://github.com/Jensway/cups-openwrt-gl-mt3600be) | 同仓库，新增 3.0 构建 |
| 架构 | 单体 cupsd 守护进程 | 模块化：libcups + cups-local + cups-sharing |
| Feed | TheMMcOfficial/lede-cups | 需新建或扩展 |
| 设备 | GL-MT3600BE (aarch64_cortex-a53) | 同设备 |

---

## 二、CUPS 3.0 架构说明

根据 [OpenPrinting CUPS 3.0 Wiki](https://github.com/OpenPrinting/cups/wiki/CUPS-3.0)：

| 组件 | 仓库 | 状态 | 作用 |
|------|------|------|------|
| **libcups** | [OpenPrinting/libcups](https://github.com/OpenPrinting/libcups) | ✅ v3.0.0 已发布 (2025-01) | 核心库 + 工具 (ippfind, ipptool, ipptransform 等) |
| **cups-local** | [OpenPrinting/cups-local](https://github.com/OpenPrinting/cups-local) | 🟡 计划 2025 年 8–9 月 | 用户进程，临时队列，lp/lpr 等命令 |
| **cups-sharing** | [OpenPrinting/cups-sharing](https://github.com/OpenPrinting/cups-sharing) | 🟡 计划 2025 年 8–9 月 | root 进程，永久队列，Web 界面，共享打印 |

**cups-local** 和 **cups-sharing** 均基于 [PAPPL](https://github.com/michaelrsweet/pappl)（Printer Application Framework）。

---

## 三、依赖关系

```
cups-sharing / cups-local
    └── PAPPL
            ├── libcups 3.0+
            ├── ZLIB
            ├── TLS (GnuTLS / OpenSSL / LibreSSL)
            ├── Avahi 或 mDNSResponder
            └── 可选：libpng, libjpeg-turbo, libusb
```

OpenWrt 21.02 上通常已有：zlib、openssl、libpng、libjpeg-turbo、libusb。需要确认 Avahi 或 mDNSResponder 的可用性。

---

## 四、升级难点

1. **lede-cups 仅支持 CUPS 2.x**  
   当前 [TheMMcOfficial/lede-cups](https://github.com/TheMMcOfficial/lede-cups) 的 Makefile 面向 CUPS 2.x 单体结构，无法直接用于 3.0。

2. **需新增 OpenWrt 包**  
   至少需要为以下组件编写 OpenWrt Makefile：
   - `libcups` 3.0（可参考现有 libcups，但源码 URL、版本、构建选项不同）
   - `PAPPL`（目前无现成 OpenWrt 包）
   - `cups-sharing`（或 `cups-local`，视路由器使用场景而定）

3. **cups-sharing / cups-local 尚未正式发布**  
   按计划 2025 年 8–9 月才有 3.0.0，当前可能只有开发版或 RC。

4. **API 变更**  
   libcups 3.0 移除大量废弃 API，cups-filters 等依赖需适配。

---

## 五、推荐实施路径

### 阶段一：准备（当前可做）

1. **Fork Jensway 仓库**，新建分支 `cups-3.0`。
2. **在本地或 Actions 中验证 libcups 3.0 构建**：
   - 新建 `feeds/cups/libcups3/` 或类似目录
   - 编写 `Makefile`，使用 [libcups v3.0.0](https://github.com/OpenPrinting/libcups/releases/tag/v3.0.0) 源码
   - 在 OpenWrt SDK 中单独编译 libcups 3.0，确认无依赖缺失

3. **调研 PAPPL 在 OpenWrt 上的构建**：
   - 参考 [recipes-pappl](https://github.com/michaelrsweet/recipes-pappl)（Yocto）
   - 编写 OpenWrt 的 PAPPL Makefile，依赖 libcups 3.0

### 阶段二：等待 cups-sharing 稳定（约 2025 年 8–9 月后）

1. 关注 [cups-sharing releases](https://github.com/OpenPrinting/cups-sharing/releases)。
2. 为 cups-sharing 编写 OpenWrt Makefile。
3. 在 GL-MT3600BE 上测试：Web 界面、永久队列、AirPrint 等。

### 阶段三：整合到 Jensway 工作流

1. 修改 `.github/workflows/build-cups.yml`：
   - 新增 workflow：`Build CUPS 3.0 for GL-MT3600BE`
   - 或增加 `version` 输入参数，在 2.4.16 与 3.0 之间切换。

2. 更新 `openwrt-cups-overlay`：
   - 为 cups-sharing 提供 `cups-sharing.init` 等启动脚本
   - 提供 `cups-sharing.conf` 等配置模板

3. 更新 `CUPS升级指南-GL-MT3600BE.md`：
   - 增加 3.0 的安装步骤与包列表
   - 说明 2.x 与 3.x 的配置差异

---

## 六、可选的快速验证方案

若希望尽早验证 CUPS 3.0 在 OpenWrt 上的可行性，可先只构建 **libcups 3.0**：

- libcups 3.0 提供：`ippfind`、`ipptool`、`ippeveprinter`、`ipptransform` 等工具
- 不包含 cupsd / Web 界面，但可验证依赖和交叉编译是否通过
- 为后续 PAPPL、cups-sharing 的移植铺路

---

## 七、参考链接

- [OpenPrinting CUPS 3.0 介绍](https://openprinting.github.io/cups/cups3.html)
- [OpenPrinting CUPS 3.0 Wiki](https://github.com/OpenPrinting/cups/wiki/CUPS-3.0)
- [libcups v3.0.0 Release](https://github.com/OpenPrinting/libcups/releases/tag/v3.0.0)
- [PAPPL - Printer Application Framework](https://github.com/michaelrsweet/pappl)
- [Jensway 仓库](https://github.com/Jensway/cups-openwrt-gl-mt3600be)
- [Jensway 构建工作流](https://github.com/Jensway/cups-openwrt-gl-mt3600be/blob/main/.github/workflows/build-cups.yml)

---

## 八、下一步建议

1. **短期**：继续使用 CUPS 2.4.16，功能与安全性已足够。
2. **中期**：在 Jensway 仓库中新建 `cups-3.0` 分支，先完成 libcups 3.0 的 OpenWrt 构建。
3. **长期**：待 cups-sharing 3.0.0 发布后，补充 PAPPL 与 cups-sharing 的 OpenWrt 包，并整合进同一构建流程。

如需，我可以根据你当前的仓库结构，起草一份 **libcups 3.0 的 OpenWrt Makefile 初稿**，便于你直接开始阶段一的验证。
