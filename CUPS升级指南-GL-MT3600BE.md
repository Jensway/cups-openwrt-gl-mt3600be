# CUPS 2.4.16 升级指南 (GL-MT3600BE)

## 项目信息

- **GitHub 仓库**: https://github.com/Jensway/cups-openwrt-gl-mt3600be
- **Actions 页面**: https://github.com/Jensway/cups-openwrt-gl-mt3600be/actions
- **设备**: GL-MT3600BE (Beryl 7)
- **架构**: aarch64_cortex-a53, OpenWrt 21.02-SNAPSHOT
- **原版本**: CUPS 2.3.3op2 → **目标版本**: CUPS 2.4.16

---

## 一、如何重新构建 ipk

1. 打开 https://github.com/Jensway/cups-openwrt-gl-mt3600be/actions
2. 点击 `Build CUPS 2.4.16 for GL-MT3600BE`
3. 点右侧 `Run workflow`
4. 等待构建完成（约 10-15 分钟）
5. 在构建结果底部下载 `cups-2.4.16-ipk` 压缩包

---

## 二、只需安装这 7 个 ipk（其余不要装）

| 文件名 | 说明 |
|--------|------|
| libcups_2.4.16-1_aarch64_cortex-a53.ipk | 核心库（必须） |
| libcupsimage_2.4.16-1_aarch64_cortex-a53.ipk | 图片库（必须） |
| cups_2.4.16-1_aarch64_cortex-a53.ipk | 主程序 cupsd（必须） |
| cups-bsd_2.4.16-1_aarch64_cortex-a53.ipk | BSD 命令 lpr/lpq（推荐） |
| cups-client_2.4.16-1_aarch64_cortex-a53.ipk | 客户端工具（推荐） |
| cups-filters_2.4.16-1_aarch64_cortex-a53.ipk | 过滤器（推荐） |
| cups-ppdc_2.4.16-1_aarch64_cortex-a53.ipk | PPD 工具（可选） |

**不要装的**：libc、libgcc1、libpthread、librt、libstdcpp6、libatomic1、zlib、zlib-dev、libusb、libjpeg-turbo、libpng（路由器里已有）

---

## 三、从 Windows 传文件到路由器

```powershell
cd "下载目录\解压后的ipk文件夹"
scp libcups_2.4*.ipk libcupsimage_2.4*.ipk cups_2.4*.ipk cups-bsd*.ipk cups-client*.ipk cups-filters*.ipk cups-ppdc*.ipk root@192.168.8.1:/tmp/
```

---

## 四、路由器上执行安装

```sh
ssh root@192.168.8.1

# 1. 备份旧配置
cp -a /etc/cups /root/cups-backup
cp /etc/config/cupsd /root/cupsd-config-backup

# 2. 停服务
/etc/init.d/cupsd stop

# 3. 卸载旧包
opkg remove cups cups-bsd cups-client cups-filters cups-ppdc --force-depends
opkg remove libcupscgi libcupsmime libcupsppdc --force-depends
opkg remove libcupsimage --force-depends
opkg remove libcups --force-depends

# 4. 安装新包（先库后主程序）
opkg install /tmp/libcups_2.4*.ipk
opkg install /tmp/libcupsimage_2.4*.ipk
opkg install /tmp/cups_2.4*.ipk
opkg install /tmp/cups-bsd_2.4*.ipk
opkg install /tmp/cups-client_2.4*.ipk
opkg install /tmp/cups-filters_2.4*.ipk
opkg install /tmp/cups-ppdc_2.4*.ipk

# 5. 恢复打印机配置
cp /root/cups-backup/printers.conf /etc/cups/printers.conf
cp /root/cups-backup/classes.conf /etc/cups/classes.conf 2>/dev/null

# 6. 启动新版
/etc/init.d/cupsd enable
/etc/init.d/cupsd start

# 7. 验证版本
cupsd -v
```

---

## 五、Web 管理界面

浏览器打开: **http://192.168.8.1:631**

---

## 五（补充）、LuCI 服务菜单（可选）

若希望像 OpenClash 一样在路由器的**服务**菜单中看到 CUPS，可安装 `luci-app-cups`：

- 显示 **OpenPrinting CUPS 2.4.16**
- 一键跳转到 http://192.168.8.1:631
- 启动 / 停止服务
- 停止并禁用开机自启

详见项目中的 `luci-app-cups/README.md`。需将 `luci-app-cups` 加入 Jensway 构建流程后生成 ipk，或按 README 手动编译/复制安装。

---

## 六、如果需要回滚到旧版本

```sh
# 卸载新版
opkg remove cups cups-bsd cups-client cups-filters cups-ppdc --force-depends
opkg remove libcupsimage --force-depends
opkg remove libcups --force-depends

# 恢复备份的配置
cp -a /root/cups-backup/* /etc/cups/

# 重新安装旧版（需要旧的 ipk 或从软件源安装）
# 然后重启 cupsd
/etc/init.d/cupsd start
```

---

## 七、构建原理简述

- 使用 GitHub Actions 云端编译（不需要本地搭建编译环境）
- 基于 OpenWrt 21.02.7 的 mediatek-mt7622 SDK（aarch64_cortex-a53）
- 拉取 lede-cups feed，用 sed 就地修改版本号从 2.3.0 到 2.4.16
- 修改源码下载地址从 Apple → OpenPrinting
- 删除不兼容的旧补丁
- 编译生成 ipk

---

## 八、2.4.16 相比 2.3.3op2 的主要改进

- 修复 10 个 CVE 安全漏洞
- 支持 AirPrint / Mopria（手机直接打印）
- Web UI 暗色模式
- IPP Everywhere 直接支持
- 大量内存泄漏和稳定性修复
- 详见源码目录中的 CHANGES.md
