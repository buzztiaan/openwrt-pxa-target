#!/bin/bash
# Calculates flash partition sizes, updates the template DTS file
# and creates empty jffs2 partitions

[ $# -eq 6 ] || {
    echo "SYNTAX: $0 <kerneldir> <bindir> <img_prefix> <dtsdir> <kdir_tmp> <staging_dir_host>"
    exit 1
}

# Defaults
FLASH_BLOCKSIZE=64
FLASH_SZ=128
UBOOT_SZ=4
UBOOT_ENV_SZ=1

# Calculate partition sizes
KERNEL_SZ=`du -B "$FLASH_BLOCKSIZE"k "$2/$3-uImage" | awk '{print $1}'`
KERNEL_DT_SZ=`printf %x $(($KERNEL_SZ * $FLASH_BLOCKSIZE * 1024))`
ROOTFS_ADDR=`printf %x $((($UBOOT_SZ + $UBOOT_ENV_SZ + $KERNEL_SZ) * $FLASH_BLOCKSIZE * 1024))`
ROOTFS_SZ=`du -B "$FLASH_BLOCKSIZE"k "$2/$3-squashfs.img" | awk '{print $1}'`
JFFS2_ADDR=`printf %x $((($UBOOT_SZ + $UBOOT_ENV_SZ + $KERNEL_SZ + $ROOTFS_SZ) * $FLASH_BLOCKSIZE * 1024))`
SQUASHFS_SZ=`printf %x $(($ROOTFS_SZ * $FLASH_BLOCKSIZE * 1024))`
JFFS_SIZE=$((($FLASH_SZ - $UBOOT_SZ - $UBOOT_ENV_SZ - $KERNEL_SZ - $ROOTFS_SZ) * $FLASH_BLOCKSIZE * 1024))

# Replace partition sizes in the DTS template
sed -e "s:DT_SZ_KERNEL:${KERNEL_DT_SZ}:" -e "s:DT_ADDR_SQUASH:${ROOTFS_ADDR}:g" -e "s:DT_SZ_SQUASH:${SQUASHFS_SZ}:" -e "s:DT_ADDR_JFFS2:${JFFS2_ADDR}:g" <../dts/zipit-z2_template.dts >$4/zipit-z2.new.dts

# Create the empty jffs2 partition
mkdir -p "$5/empty_jffs"
"$6/bin/mkfs.jffs2" -v -X lzma -y 80:lzma -y 70:zlib \
    --pad="$JFFS_SIZE" \
    --little-endian --squash -e 64KiB \
    -d "$5/empty_jffs" \
    -o "$2/$3-overlay.jffs2"
