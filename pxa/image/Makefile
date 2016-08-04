#
# Copyright (C) 2008-2012 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/image.mk
include $(INCLUDE_DIR)/host.mk

SQUASHFSCOMP:=xz
FLASH_BLOCKSIZE:=64
FLASH_SZ:=128
UBOOT_SZ:=4
UBOOT_ENV_SZ:=1

define MkuImage
	# Tack DTB onto end of kernel zImage
	cat $(KDIR)/zImage $(DTS_DIR)/zipit-z2.dtb > $(KDIR_TMP)/zImage-dtb
	# Make the uImage
	mkimage -A Arm \
		-O linux \
		-C none \
		-T kernel \
		-a 0xA0008000 -e 0xA0008000 \
		-n uImage-dtb -d $(KDIR_TMP)/zImage-dtb $(KDIR_TMP)/uImage
	dd if=$(KDIR_TMP)/uImage of=$(BIN_DIR)/$(IMG_PREFIX)-uImage bs=$(FLASH_BLOCKSIZE)k conv=sync
endef

# Build a fake flash image for usage in Qemu
define Image/Build/Gumstix
	dd if=/dev/zero bs=128k count=256 of=$(BIN_DIR)/$(IMG_PREFIX)-$(1)-qemu-flash.img
	dd if=$(BIN_DIR)/openwrt-pxa-gumstix-u-boot.bin conv=notrunc bs=128k \
		of=$(BIN_DIR)/$(IMG_PREFIX)-$(1)-qemu-flash.img
	dd if=$(KDIR)/root.$(1) conv=notrunc bs=128k seek=2 \
		of=$(BIN_DIR)/$(IMG_PREFIX)-$(1)-qemu-flash.img
	dd if=$(KDIR)/uImage conv=notrunc bs=128k seek=248 \
		of=$(BIN_DIR)/$(IMG_PREFIX)-$(1)-qemu-flash.img
endef

define Image/Build/jffs2-64k
	dd if=$(KDIR)/root.$(1) of=$(BIN_DIR)/$(IMG_PREFIX)-$(1).img bs=64k conv=sync
endef

define Image/Build/squashfs
	$(call prepare_generic_squashfs,$(KDIR)/root.squashfs)
	dd if=$(KDIR)/root.$(1) of=$(BIN_DIR)/$(IMG_PREFIX)-$(1).img bs=$(FLASH_BLOCKSIZE)k conv=sync
endef

define Image/Build/firmware
	# Build uImage so we can get closest approximate size for kernel partition
	$(call MkuImage)
	# Rebuild DTS with our template and updated partition sizes
	./gen_dts.sh $(KDIR) $(BIN_DIR) $(IMG_PREFIX) $(DTS_DIR) $(KDIR_TMP) $(STAGING_DIR_HOST)
	$(call Image/BuildDTB,$(DTS_DIR)/zipit-z2.new.dts,$(DTS_DIR)/zipit-z2.dtb)
	# Rebuild the uImage with our new DTB
	$(call MkuImage)
	# Combine everything into one firmware file
	cat $(BIN_DIR)/$(IMG_PREFIX)-uImage \
		$(BIN_DIR)/$(IMG_PREFIX)-squashfs.img \
		$(BIN_DIR)/$(IMG_PREFIX)-overlay.jffs2 >$(BIN_DIR)/$(IMG_PREFIX)-firmware.img
	# Verify size of firmware to make sure it will fit in flash
	$(call check-filesize,$(BIN_DIR)/$(IMG_PREFIX)-firmware.img,8060928)
endef

define check-filesize
	@if [ "$$$$(stat -c%s $(1))" -gt $(2) ]; then \
		echo "WARNING: file $(1) is too big!" >&2; \
		exit 1; \
	fi
endef

define Image/Build
	$(call Image/Build/$(1),$(1))
	$(call Image/Build/$(PROFILE),$(1))
	$(call Image/Build/firmware,$(1))
endef

$(eval $(call BuildImage))
