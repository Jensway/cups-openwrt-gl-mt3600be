#
# LuCI Support for OpenPrinting CUPS 2.4.16
# 适配 GL-MT3600BE，显示在服务菜单，支持启动/停止/跳转 Web 管理
#

include $(TOPDIR)/rules.mk

LUCI_TITLE:=OpenPrinting CUPS 2.4.16
LUCI_DESCRIPTION:=打印服务器管理 - 支持启动/停止服务，跳转 Web 管理界面
LUCI_DEPENDS:=+cups
PKG_VERSION:=1.0
PKG_RELEASE:=1

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
