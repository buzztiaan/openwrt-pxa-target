# openwrt-pxa-target
This target feed adds support for the Zipit Z2 (pxa) platform to openwrt. It has been tested with openwrt trunk as of commit [1e22c9b9eb691878156dfe32fb1e117737f1d248](https://github.com/openwrt/openwrt/commit/1e22c9b9eb691878156dfe32fb1e117737f1d248) (Wed Apr 27 2016)

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

Run _make_ to do the default build or run _make menuconfig_ to add/remove packages.

## Zipit Z2 Linux Kernel 4.4 Internal 8Mb FlashPartition Layout
| Contents | Size(bytes) | Start[hex] | Size[hex] |
|:--------:| -----------:| ----------:| ---------:|
| u-boot | 262144 | 0x00000 | 0x40000 |
| u-boot-env | 65536 | 0x40000 | 0x10000 |
| kernel | 1638400 | 0x50000 | 0x190000 |
| squashfs | 4259840 | 0x1E0000 | 0x410000 |
| jffs2 | 2162688 | 0x5F0000 | 0x210000 |
Verify your file sizes after compiling to ensure they will fit in the above partitions (if installing to internal flash)

## Pre-Built Package Repository
A repository of pre built packages is available and this build system configures opkg to use that repository. It is hosted at [mozzwald.com](https://mozzwald.com/zipit/index.php?dir=openwrt%2Fbleeding_edge%2F) See the README in that directory for installation instructions.
