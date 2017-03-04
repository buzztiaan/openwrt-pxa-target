# openwrt-pxa-target
This target feed adds support for the Zipit Z2 (pxa) platform to openwrt. It has been tested with openwrt trunk as of commit [1e22c9b9eb691878156dfe32fb1e117737f1d248](https://github.com/openwrt/openwrt/commit/1e22c9b9eb691878156dfe32fb1e117737f1d248) (Wed Apr 27 2016)

## Pre-Built Package Repository
Pre-compiled rootfs and packages are available. See the [Wiki](https://github.com/openwrt-zipit/openwrt-pxa-target/wiki) for more information about installation and general usage.

## Prerequisites
See the [OpenWrt Wiki page](https://wiki.openwrt.org/doc/howto/buildroot.exigence) for host system prerequisites

## Usage
Download openwrt trunk with git and checkout commit 1e22c9b9eb691878156dfe32fb1e117737f1d248:

     git clone https://github.com/openwrt/openwrt.git openwrt-zipit
     cd openwrt-zipit
     git checkout 1e22c9b9eb691878156dfe32fb1e117737f1d248

Add the pxa target feed to _feeds.conf_:

     echo "src-git pxa_target https://github.com/openwrt-zipit/openwrt-pxa-target" > feeds.conf

Update and install the target feed:

     scripts/feeds update && scripts/feeds install -p pxa_target pxa

Copy the _feeds.conf_ and default config files:

     cp feeds/pxa_target/feeds.conf ./feeds.conf
     cp feeds/pxa_target/zipit_openwrt_defconfig ./.config

Update the feeds again:

     scripts/feeds update && scripts/feeds install -a

Apply patches to openwrt and openwrt-packages:

     for f in feeds/pxa_target/patches/openwrt/*; do patch -p1 < "${f}"; done
     for f in feeds/pxa_target/patches/openwrt-packages/*; do patch -d feeds/packages -p1 < "${f}"; done

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
