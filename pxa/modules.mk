#
# Copyright (C) 2013-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

define KernelPackage/sound-zipit-z2
  SUBMENU:=Sound Support
  TITLE:=Zipit Z2 Sound Support
  KCONFIG:= \
	CONFIG_SND_PXA2XX_SOC \
	CONFIG_SND_PXA2XX_SOC_I2S \
 	CONFIG_SND_PXA2XX_AC97=n \
	CONFIG_SND_SIMPLE_CARD \
	CONFIG_SND_SOC_WM8750
  FILES:= \
	$(LINUX_DIR)/sound/core/snd-pcm-dmaengine.ko \
        $(LINUX_DIR)/sound/arm/snd-pxa2xx-lib.ko \
        $(LINUX_DIR)/sound/soc/pxa/snd-soc-pxa2xx.ko \
        $(LINUX_DIR)/sound/soc/pxa/snd-soc-pxa2xx-i2s.ko \
        $(LINUX_DIR)/sound/soc/generic/snd-soc-simple-card.ko \
        $(LINUX_DIR)/sound/soc/codecs/snd-soc-wm8750.ko
  AUTOLOAD:=$(call AutoLoad,60,snd-pcm-dmaengine snd-pxa2xx-lib snd-soc-pxa2xx snd-soc-pxa2xx-i2s snd-soc-wm8750 snd-soc-simple-card)
  DEPENDS:=@TARGET_pxa_ZipitZ2 +kmod-sound-core +kmod-sound-soc-core
  $(call AddDepends/sound)
endef

define KernelPackage/sound-zipit-z2/description
 Sound support for Zipit Z2
endef

$(eval $(call KernelPackage,sound-zipit-z2))

define KernelPackage/pxa27x-udc
  SUBMENU:=$(USB_MENU)
  TITLE:=Support for PXA27x USB device controller
  KCONFIG:=CONFIG_USB_PXA27X
  DEPENDS:=@TARGET_pxa +USB_GADGET_SUPPORT:kmod-usb-gadget
  FILES:=$(LINUX_DIR)/drivers/usb/gadget/udc/pxa27x_udc.ko
  AUTOLOAD:=$(call AutoLoad,46,pxa27x_udc)
  $(call AddDepends/usb)
endef

define KernelPackage/pxa27x-udc/description
  Kernel support for PXA27x USB device.
endef

$(eval $(call KernelPackage,pxa27x-udc))
