# luci-app-cups

OpenPrinting CUPS 2.4.16 的 LuCI 管理界面，类似 OpenClash 一样出现在**服务**菜单中。

## 功能

- 显示 **OpenPrinting CUPS 2.4.16** 版本
- 显示运行状态（运行中 / 已停止）
- 一键跳转到 Web 管理界面（http://路由器IP:631）
- **启动服务** / **停止服务**
- **停止并禁用自启**（从开机自启中移除）
- 完全卸载说明（opkg 命令）

## 安装方式

### 方式一：通过 Jensway 构建（推荐）

将本目录加入 Jensway 仓库的构建流程，与 CUPS ipk 一起编译出 `luci-app-cups_*.ipk`，然后通过 opkg 安装。

### 方式二：手动编译

1. 将 `luci-app-cups` 目录复制到 OpenWrt SDK 的 `package` 或 `feeds/luci/applications` 下
2. 执行：
   ```bash
   make menuconfig
   # 在 LuCI -> Applications 中勾选 luci-app-cups
   make package/luci-app-cups/compile V=s
   ```
3. 在 `bin/packages/` 下找到生成的 `luci-app-cups_*.ipk`，传到路由器安装

### 方式三：直接复制文件（临时）

若无法编译 ipk，可手动将文件复制到路由器对应路径（需已安装 CUPS 和 LuCI）：

```
luasrc/controller/cups.lua     -> /usr/lib/lua/luci/controller/cups.lua
luasrc/model/cbi/cups/status.lua -> /usr/lib/lua/luci/model/cbi/cups/status.lua
luasrc/view/cups/status.htm    -> /usr/lib/lua/luci/view/cups/status.htm
root/etc/config/cups          -> /etc/config/cups
root/usr/share/rpcd/acl.d/luci-app-cups.json -> /usr/share/rpcd/acl.d/luci-app-cups.json
```

然后执行：
```sh
/etc/init.d/rpcd restart
```

**注意**：GL.iNet 固件若使用自定义界面而非标准 LuCI，可能无法显示。需确认路由器有 LuCI（例如通过 192.168.8.1/cgi-bin/luci 可访问）。

## 依赖

- `cups`（已安装 CUPS 2.4.16）
- LuCI（OpenWrt 标准 Web 管理）

## 集成到 Jensway 构建

在 Jensway 仓库的 `.github/workflows/build-cups.yml` 中：

1. 添加 luci 和 luci-app-cups 到 feeds，或
2. 将本目录放入 `openwrt-cups-overlay`，在「Copy config files」步骤后增加复制 luci-app-cups 的步骤
3. 在 `Configure and enable CUPS` 步骤中增加：
   ```bash
   echo "CONFIG_PACKAGE_luci-app-cups=m" >> .config
   ```

## 卸载

仅卸载 LuCI 界面（保留 CUPS）：
```sh
opkg remove luci-app-cups
```

完全卸载 CUPS 及界面：
```sh
opkg remove luci-app-cups cups cups-bsd cups-client cups-filters cups-ppdc libcupsimage libcups
```
