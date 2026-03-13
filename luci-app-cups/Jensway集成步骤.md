# luci-app-cups 集成到 Jensway 构建的详细步骤

## 一、将 luci-app-cups 加入 Jensway 仓库

1. Fork 或克隆 [Jensway/cups-openwrt-gl-mt3600be](https://github.com/Jensway/cups-openwrt-gl-mt3600be)
2. 将本地的 `luci-app-cups` 整个目录复制到 Jensway 仓库**根目录**下，与 `openwrt-cups-overlay` 同级
3. 提交并推送

```
Jensway 仓库结构（集成后）：
├── .github/workflows/
│   └── build-cups.yml
├── openwrt-cups-overlay/
├── luci-app-cups/          ← 新增
│   ├── Makefile
│   ├── luasrc/
│   ├── root/
│   └── ...
└── ...
```

---

## 二、修改 `.github/workflows/build-cups.yml`

### 2.1 在「Copy config files」步骤中增加复制 luci-app-cups

找到：

```yaml
- name: Copy config files
  run: |
    cd $HOME/sdk/openwrt-sdk
    mkdir -p feeds/cups/cups/files/etc/cups
    cp $GITHUB_WORKSPACE/openwrt-cups-overlay/cups/files/cupsd.init feeds/cups/cups/files/
    cp $GITHUB_WORKSPACE/openwrt-cups-overlay/cups/files/etc/cups/cupsd.conf feeds/cups/cups/files/etc/cups/

    # Re-install feeds
    ./scripts/feeds update -i
    ./scripts/feeds install -a
```

在 `# Re-install feeds` 之前增加：

```yaml
    # 复制 luci-app-cups 到 package 目录
    cp -r $GITHUB_WORKSPACE/luci-app-cups package/
```

### 2.2 在「Configure and enable CUPS」步骤中增加 luci-app-cups

找到：

```yaml
    echo "CONFIG_PACKAGE_cups-ppdc=m" >> .config

    make defconfig
```

在 `echo "CONFIG_PACKAGE_cups-ppdc=m" >> .config` 后面增加一行：

```yaml
    echo "CONFIG_PACKAGE_luci-app-cups=m" >> .config
```

### 2.3 在「Fix install paths and rebuild」步骤之后增加构建 luci-app-cups

找到：

```yaml
    make package/cups/compile V=s -j1

- name: Collect all CUPS related IPKs
```

在 `make package/cups/compile V=s -j1` 与 `- name: Collect all CUPS related IPKs` 之间插入新步骤：

```yaml
- name: Build luci-app-cups
  run: |
    cd $HOME/sdk/openwrt-sdk
    make package/luci-app-cups/compile V=s -j1
```

---

## 三、完整修改后的关键片段（供对照）

```yaml
# Copy config files 步骤
- name: Copy config files
  run: |
    cd $HOME/sdk/openwrt-sdk
    mkdir -p feeds/cups/cups/files/etc/cups
    cp $GITHUB_WORKSPACE/openwrt-cups-overlay/cups/files/cupsd.init feeds/cups/cups/files/
    cp $GITHUB_WORKSPACE/openwrt-cups-overlay/cups/files/etc/cups/cupsd.conf feeds/cups/cups/files/etc/cups/
    cp -r $GITHUB_WORKSPACE/luci-app-cups package/
    ./scripts/feeds update -i
    ./scripts/feeds install -a

# Configure 步骤
    echo "CONFIG_PACKAGE_cups-ppdc=m" >> .config
    echo "CONFIG_PACKAGE_luci-app-cups=m" >> .config
    make defconfig

# 新增 Build luci-app-cups 步骤（在 Fix install paths 之后、Collect 之前）
- name: Build luci-app-cups
  run: |
    cd $HOME/sdk/openwrt-sdk
    make package/luci-app-cups/compile V=s -j1
```

---

## 四、构建与安装

1. 在 Jensway 仓库的 Actions 页面点击 **Run workflow**
2. 构建完成后，在 Artifacts 中下载 `cups-2.4.16-ipk`
3. 解压后应包含 `luci-app-cups_1.0-1_aarch64_cortex-a53.ipk`
4. 将 CUPS 的 7 个 ipk 和 `luci-app-cups_*.ipk` 传到路由器
5. 安装顺序：先装 CUPS 7 个包，再装 luci-app-cups：
   ```sh
   opkg install /tmp/luci-app-cups_*.ipk
   ```
6. 刷新路由器 Web 界面，在**服务**菜单中应出现 **OpenPrinting CUPS 2.4.16**

---

## 五、若构建失败

- **找不到 luci.mk**：确认 SDK 的 `feeds.conf.default` 包含 luci，且已执行 `feeds update -a`
- **luci-app-cups 未出现在 menuconfig**：确认已复制到 `package/` 且目录名正确
- **依赖 cups 报错**：先完成 CUPS 的构建，再构建 luci-app-cups
