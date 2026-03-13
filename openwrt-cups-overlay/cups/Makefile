#
# OpenWrt Makefile for CUPS 2.4.16
# Adapted from TheMMcOfficial/lede-cups for CUPS 2.4.x series
#

include $(TOPDIR)/rules.mk

PKG_NAME:=cups
PKG_VERSION:=2.4.16
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-source.tar.gz
PKG_SOURCE_URL:=https://github.com/OpenPrinting/cups/releases/download/v$(PKG_VERSION)
PKG_HASH:=skip

TARGET_LDFLAGS+=-Wl,-rpath-link=$(STAGING_DIR)/usr/lib

include $(INCLUDE_DIR)/package.mk

define Package/cups/Default
 URL:=http://www.cups.org/
 SUBMENU:=Printing
endef

define Package/cups
$(call Package/cups/Default)
 SECTION:=net
 CATEGORY:=Network
 DEPENDS:=+libcups +libusb-1.0 +libstdcpp
 TITLE:=Common UNIX Printing System (daemon)
endef

define Package/cups/description
 Common UNIX Printing System (daemon) - version 2.4.16
endef

define Package/cups/conffiles
/etc/cups/classes.conf
/etc/cups/cupsd.conf
/etc/cups/printers.conf
endef

define Package/cups-bsd
$(call Package/cups/Default)
 SECTION:=net
 CATEGORY:=Network
 DEPENDS:=+libcups
 TITLE:=Common UNIX Printing System - BSD commands (old)
endef

define Package/cups-bsd/description
 Common UNIX Printing System - BSD commands (old)
endef

define Package/cups-client
$(call Package/cups/Default)
 SECTION:=net
 CATEGORY:=Network
 DEPENDS:=+libcups +libcupsimage
 TITLE:=Common UNIX Printing System - Client commands
endef

define Package/cups-client/conffiles
/etc/cups/client.conf
endef

define Package/cups-client/description
 Common UNIX Printing System - Client commands
endef

define Package/cups-filters
$(call Package/cups/Default)
 SECTION:=net
 CATEGORY:=Network
 DEPENDS:=+libcupsimage
 TITLE:=Common UNIX Printing System - Filter
endef

define Package/cups-filters/description
 Common UNIX Printing System - Filter
endef

define Package/cups-ppdc
$(call Package/cups/Default)
 SECTION:=net
 CATEGORY:=Network
 DEPENDS:=+libcups +zlib +libpthread +libpng +libjpeg +libstdcpp
 TITLE:=Common UNIX Printing System - PPDC utils
endef

define Package/cups-ppdc/description
 Common UNIX Printing System - PPDC utils
endef

define Package/libcups
$(call Package/cups/Default)
 SECTION:=libs
 CATEGORY:=Libraries
 DEPENDS:=+zlib +libpthread +libpng +libjpeg
 TITLE:=Common UNIX Printing System - Core library
endef

define Package/libcups/description
 Common UNIX Printing System - Core library
endef

define Package/libcupsimage
$(call Package/cups/Default)
 SECTION:=libs
 CATEGORY:=Libraries
 DEPENDS:=+libcups
 TITLE:=Common UNIX Printing System - Image library
endef

define Package/libcupsimage/description
 Common UNIX Printing System - Image library
endef

define Build/Configure
	$(call Build/Configure/Default, \
		--with-cups-user="nobody" \
		--with-cups-group="nogroup" \
		--with-system-groups="root" \
		--with-pdftops="none" \
		--with-tls=no \
		--libdir=/usr/lib \
		--without-perl \
		--without-python \
		--without-php \
		--enable-default-shared \
		--enable-shared \
		--disable-static \
		--enable-image \
		--enable-libusb \
		--disable-acl \
		--disable-dnssd \
		--disable-dbus \
		--disable-avahi \
		--disable-launchd \
		--disable-ldap \
		--disable-pam \
		--disable-slp \
		--disable-gssapi \
		--disable-tiff, \
		UNAME="Linux" \
		LIBS="$(TARGET_LDFLAGS) -lz -lpng -ljpeg" \
 )
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		DSTROOT="$(PKG_INSTALL_DIR)" \
		STRIP="/bin/true" \
		all install

	# Debug: show what was installed
	-@ls -la $(PKG_INSTALL_DIR)/usr/lib/ 2>/dev/null || true
	-@find $(PKG_INSTALL_DIR) -name 'libcups.so*' -type f 2>/dev/null || true

	# Fix library installation paths after install
	# CUPS may install to lib64 or /usr/local/lib instead of /usr/lib
	(cd $(PKG_INSTALL_DIR) && \
	 (if [ -d usr/lib64 ] && [ ! -d usr/lib ]; then mv usr/lib64 usr/lib; fi; \
	 if [ -d usr/lib64 ] && [ -d usr/lib ]; then cp -a usr/lib64/* usr/lib/ 2>/dev/null; rm -rf usr/lib64; fi; \
	 if [ -d usr/local/lib ]; then mkdir -p usr/lib; cp -a usr/local/lib/* usr/lib/ 2>/dev/null; fi; \
	 if [ -d usr/local ]; then cp -a usr/local/bin/* usr/bin/ 2>/dev/null; cp -a usr/local/sbin/* usr/sbin/ 2>/dev/null; fi))
endef

define Package/cups/install
 rm -rf $(1)/etc/cups
 $(INSTALL_DIR) $(1)/etc/cups
 $(CP) $(PKG_INSTALL_DIR)/etc/cups/* $(1)/etc/cups/
 rm -rf $(1)/etc/cups/certs
 ln -sf /tmp $(1)/etc/cups/certs
 rm -f $(1)/usr/bin/cups-config
 $(INSTALL_DIR) $(1)/usr/lib/cups
 $(CP) $(PKG_INSTALL_DIR)/usr/lib/cups/backend $(1)/usr/lib/cups
 $(CP) $(PKG_INSTALL_DIR)/usr/lib/cups/cgi-bin $(1)/usr/lib/cups
 $(CP) $(PKG_INSTALL_DIR)/usr/lib/cups/daemon $(1)/usr/lib/cups
 $(CP) $(PKG_INSTALL_DIR)/usr/lib/cups/driver $(1)/usr/lib/cups
 $(CP) $(PKG_INSTALL_DIR)/usr/lib/cups/monitor $(1)/usr/lib/cups
 $(INSTALL_DIR) $(1)/usr/share/cups/templates
 $(CP) $(PKG_INSTALL_DIR)/usr/share/cups/templates/*.tmpl \
 $(1)/usr/share/cups/templates/
 $(INSTALL_DIR) $(1)/usr/share/cups/mime
 $(CP) $(PKG_INSTALL_DIR)/usr/share/cups/mime/* $(1)/usr/share/cups/mime/
 $(INSTALL_DIR) $(1)/usr/share/doc/cups
 $(CP) $(PKG_INSTALL_DIR)/usr/share/doc/cups/*.*html \
 $(1)/usr/share/doc/cups/ 2>/dev/null || true
 $(CP) $(PKG_INSTALL_DIR)/usr/share/doc/cups/*.css \
 $(1)/usr/share/doc/cups/ 2>/dev/null || true
 $(CP) $(PKG_INSTALL_DIR)/usr/share/doc/cups/*.txt \
 $(1)/usr/share/doc/cups/ 2>/dev/null || true
 if [ -d $(PKG_INSTALL_DIR)/usr/share/doc/cups/images ]; then \
 $(CP) $(PKG_INSTALL_DIR)/usr/share/doc/cups/images \
 $(1)/usr/share/doc/cups/; \
 fi
 $(INSTALL_DIR) $(1)/usr/sbin
 if [ -d ./files/etc/cups ]; then \
 $(CP) ./files/etc/cups/* $(1)/etc/cups/; \
 fi
 $(INSTALL_DIR) $(1)/etc/init.d
 if [ -f ./files/cupsd.init ]; then \
 $(INSTALL_BIN) ./files/cupsd.init $(1)/etc/init.d/cupsd; \
 fi
 $(INSTALL_BIN) \
 $(PKG_INSTALL_DIR)/usr/sbin/cupsctl \
 $(1)/usr/sbin/
 $(INSTALL_BIN) \
 $(PKG_INSTALL_DIR)/usr/sbin/cupsd \
 $(1)/usr/sbin/
 chmod 700 $(1)/usr/lib/cups/backend/usb
endef

define Package/cups-bsd/install
 $(INSTALL_DIR) $(1)/usr/bin
 $(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/lprm $(1)/usr/bin/
 $(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/lpq $(1)/usr/bin/
 $(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/lpr $(1)/usr/bin/
 $(INSTALL_DIR) $(1)/usr/sbin
 $(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/lpc $(1)/usr/sbin/
endef

define Package/cups-client/install
 $(INSTALL_DIR) $(1)/usr/bin
 $(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/lp $(1)/usr/bin/
 $(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/cancel $(1)/usr/bin/
 $(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/cupstestppd $(1)/usr/bin/ 2>/dev/null || true
 $(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/ipptool $(1)/usr/bin/
 $(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/lpoptions $(1)/usr/bin/
 $(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/lpstat $(1)/usr/bin/
 $(INSTALL_DIR) $(1)/usr/sbin
 $(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/cupsaccept $(1)/usr/sbin/
 $(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/cupsfilter $(1)/usr/sbin/ 2>/dev/null || true
 $(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/lpadmin $(1)/usr/sbin/
 $(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/lpinfo $(1)/usr/sbin/
 $(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/lpmove $(1)/usr/sbin/
 (cd $(1)/usr/sbin; ln -sf cupsaccept accept; ln -sf cupsaccept cupsenable; ln -sf cupsaccept cupsdisable; ln -sf cupsaccept reject; ln -sf cupsaccept cupsreject;)
endef

define Package/cups-filters/install
 $(INSTALL_DIR) $(1)/usr/lib/cups/filter
 $(CP) $(PKG_INSTALL_DIR)/usr/lib/cups/filter/commandtops $(1)/usr/lib/cups/filter/ 2>/dev/null || true
 $(CP) $(PKG_INSTALL_DIR)/usr/lib/cups/filter/gziptoany $(1)/usr/lib/cups/filter/ 2>/dev/null || true
 $(CP) $(PKG_INSTALL_DIR)/usr/lib/cups/filter/pstops $(1)/usr/lib/cups/filter/ 2>/dev/null || true
 $(CP) $(PKG_INSTALL_DIR)/usr/lib/cups/filter/rastertoepson $(1)/usr/lib/cups/filter/ 2>/dev/null || true
 $(CP) $(PKG_INSTALL_DIR)/usr/lib/cups/filter/rastertohp $(1)/usr/lib/cups/filter/ 2>/dev/null || true
 $(CP) $(PKG_INSTALL_DIR)/usr/lib/cups/filter/rastertolabel $(1)/usr/lib/cups/filter/ 2>/dev/null || true
 $(CP) $(PKG_INSTALL_DIR)/usr/lib/cups/filter/rastertopwg $(1)/usr/lib/cups/filter/ 2>/dev/null || true
 if [ -f $(1)/usr/lib/cups/filter/rastertolabel ]; then \
 (cd $(1)/usr/lib/cups/filter; ln -sf rastertolabel rastertodymo;) \
 fi
endef

define Package/cups-ppdc/install
 $(INSTALL_DIR) $(1)/usr/bin
 $(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/ppdc $(1)/usr/bin/ 2>/dev/null || true
 $(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/ppdhtml $(1)/usr/bin/ 2>/dev/null || true
 $(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/ppdi $(1)/usr/bin/ 2>/dev/null || true
 $(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/ppdmerge $(1)/usr/bin/ 2>/dev/null || true
 $(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/ppdpo $(1)/usr/bin/ 2>/dev/null || true
endef

define Package/libcups/install
 $(INSTALL_DIR) $(1)/usr/lib
 # Try to find libcups.so in various locations (check standard paths first)
 $(CP) $(PKG_INSTALL_DIR)/usr/lib/libcups.so* $(1)/usr/lib/ 2>/dev/null || \
 $(CP) $(PKG_INSTALL_DIR)/usr/lib64/libcups.so* $(1)/usr/lib/ 2>/dev/null || \
 $(CP) $(PKG_INSTALL_DIR)/usr/local/lib/libcups.so* $(1)/usr/lib/ 2>/dev/null || \
 $(CP) $$(find $(PKG_INSTALL_DIR) -name 'libcups.so*' -type f 2>/dev/null) $(1)/usr/lib/ 2>/dev/null || true
endef

define Package/libcupsimage/install
 $(INSTALL_DIR) $(1)/usr/lib
 # Try to find libcupsimage.so in various locations
 $(CP) $(PKG_INSTALL_DIR)/usr/lib/libcupsimage.so* $(1)/usr/lib/ 2>/dev/null || \
 $(CP) $(PKG_INSTALL_DIR)/usr/lib64/libcupsimage.so* $(1)/usr/lib/ 2>/dev/null || \
 $(CP) $(PKG_INSTALL_DIR)/usr/local/lib/libcupsimage.so* $(1)/usr/lib/ 2>/dev/null || \
 $(CP) $$(find $(PKG_INSTALL_DIR) -name 'libcupsimage.so*' -type f 2>/dev/null) $(1)/usr/lib/ 2>/dev/null || true
endef

define Build/InstallDev
 $(INSTALL_DIR) $(2)/bin
 $(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/cups-config $(2)/bin/
 $(INSTALL_DIR) $(1)/usr/include
 $(CP) $(PKG_INSTALL_DIR)/usr/include/cups $(1)/usr/include/
 $(INSTALL_DIR) $(1)/usr/lib
 $(CP) $(PKG_INSTALL_DIR)/usr/lib/libcups*.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,cups))
$(eval $(call BuildPackage,libcups))
$(eval $(call BuildPackage,libcupsimage))
$(eval $(call BuildPackage,cups-bsd))
$(eval $(call BuildPackage,cups-client))
$(eval $(call BuildPackage,cups-filters))
$(eval $(call BuildPackage,cups-ppdc))
