include $(TOPDIR)/rules.mk

PKG_NAME:=openvpn_monitor
PKG_RELEASE:=1
PKG_VERSION:=1.0.0

include $(INCLUDE_DIR)/package.mk

define Package/openvpn_monitor
	CATEGORY:=Base system
	TITLE:=openvpn_monitor
	DEPENDS:=+lua +ubus +openvpn +nixio
endef

define Package/openvpn_monitor/description
	Openvpn client monitoring system
endef


define Build/Compile
endef

define Package/openvpn_monitor/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/usr/lib/lua/
	$(INSTALL_BIN) ./files/openvpn_monitor.init $(1)/etc/init.d/openvpn_monitor
	$(INSTALL_BIN) ./files/openvpn_monitor.lua $(1)/usr/bin/
	$(INSTALL_BIN) ./files/management_commands.lua $(1)/usr/lib/lua/
endef

$(eval $(call BuildPackage,openvpn_monitor))
