# openwrt-pxa-target
This target feed adds support for the Zipit Z2 (pxa) platform to openwrt 18.06. This is a new build based on the openwrt and lede merge. Still experimental and the following instructions may or may not apply.

## Pre-Built Package Repository
Not ready

## Prerequisites
See the [OpenWrt Wiki page](https://wiki.openwrt.org/doc/howto/buildroot.exigence) for host system prerequisites

## Usage
Download openwrt with git and checkout the 'openwrt-18.06' branch:

     git clone https://github.com/openwrt/openwrt.git openwrt-zipit
     cd openwrt-zipit
     git fetch
     git checkout openwrt-18.06

Add the pxa target, zipit packages and openwrt packages feeds to _feeds.conf_:

     echo "src-git pxa_target https://github.com/openwrt-zipit/openwrt-pxa-target.git;18.06" > feeds.conf
     echo "src-git zipit_packages https://github.com/openwrt-zipit/openwrt-zipit-packages.git" >> feeds.conf
     echo "src-git packages https://github.com/openwrt/packages.git;openwrt-18.06" >> feeds.conf

Update and install the feeds:

     scripts/feeds update && scripts/feeds install -a

Apply patches to openwrt:

     for f in feeds/pxa_target/patches/openwrt/*; do patch -p1 < "${f}"; done

Copy the default config:

     cp feeds/pxa_target/zipit_openwrt_defconfig .config

Update zipit_openwrt_defconfig:

     make defconfig

Run _make_ to do the default build or run _make menuconfig_ to add/remove packages.

## Zipit Z2 Linux Kernel 4.4 Internal 8Mb FlashPartition Layout
| Mtdblock | Name | Size(bytes) | Start[hex] | Size[hex] |
|:--------:|:--------:| -----------:| ----------:| ---------:|
| 0 | u-boot | 262144 | 0x00000 | 0x40000 |
| 1 | u-boot-env | 65536 | 0x40000 | 0x10000 |
| 2 | kernel | ? | 0x50000 | ? |
| 3 | squashfs | ? | ? | ? |
| 4 | jffs2 | ? | ? | ? |
| 5 | firmware | 8060928 | 0x50000 | 0x7B0000 |

Flash partition sizes are automatically calculated at image creation time and follow the above layout. A successful build will output a "firmware" image file in the bin/pxa dir which contains the kernel, squashfs and jffs which can be written to to mtdblock5 (firmware). If you modify (add) packages (via menuconfig) and the image file is larger than 8060928 bytes, the openwrt build will exit with an error stating such. Reduce your installed packages and try again.
