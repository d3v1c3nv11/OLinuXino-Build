#!/bin/sh
#
# Simple script to create a U-Boot with all the additional parts which are
# required to be accepted by th A64 boot0.
#
# This script requires build variants and tools from several other sources.
# See the variable definitions below. When all files can be found, a U-Boot
# file is created which can be loaded by A64 boot0 just fine.
#Useed parts from : https://github.com/longsleep/build-pine64-image/blob/master/u-boot-postprocess/u-boot-postprocess.sh

set -e

# Blobs as provided in the BSP
BLOBS="../blobs"
UBOOT="../u-boot_new"
TRUSTED_FIRMWARE="../arm-trusted-firmware-a64"
TRUSTED_FIRMWARE_BUILD="release"
SUNXI_PACK_TOOLS="../sunxi-pack-tools/bin"
PLATFORM="$1"
BUILD="../build"

if [ -z $PLATFORM ];then
	PLATFORM="teres1"
fi

mkdir -p $BUILD
make -C $UBOOT ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- clean
make -C $UBOOT ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- sun50iw1p1_config
make -C $UBOOT ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- spl
cp $BLOBS/sys_config_$PLATFORM.fex $BUILD/sys_config_$PLATFORM.fex
unix2dos $BUILD/sys_config_$PLATFORM.fex
$SUNXI_PACK_TOOLS/script $BUILD/sys_config_$PLATFORM.fex
cp $UBOOT/boot0_sdcard_sun50iw1p1.bin $BUILD/boot0_$PLATFORM.bin.tmp
$SUNXI_PACK_TOOLS/update_boot0 $BUILD/boot0_$PLATFORM.bin.tmp $BUILD/sys_config_$PLATFORM.bin sdmmc_card
mv $BUILD/boot0_$PLATFORM.bin.tmp $BUILD/boot0_$PLATFORM.bin
make -C $UBOOT ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- spl
cp $UBOOT/fes1_sun50iw1p1.bin $BUILD/fes1_$PLATFORM.bin.tmp
$SUNXI_PACK_TOOLS/update_boot0 $BUILD/fes1_$PLATFORM.bin.tmp $BUILD/sys_config_$PLATFORM.bin sdmmc_card
mv $BUILD/fes1_$PLATFORM.bin.tmp $BUILD/fes1_$PLATFORM.bin
make -C $UBOOT ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf-
dtc -Odtb -o $BUILD/a64-$PLATFORM-uboot.dtb $BLOBS/a64-$PLATFORM-uboot.dts
cp $BLOBS/sys_config_uboot.fex $BUILD/sys_config_uboot.fex
unix2dos $BUILD/sys_config_uboot.fex
$SUNXI_PACK_TOOLS/script $BUILD/sys_config_uboot.fex
$SUNXI_PACK_TOOLS/update_uboot_fdt $UBOOT/u-boot-sun50iw1p1.bin $BUILD/a64-$PLATFORM-uboot.dtb $BUILD/u-boot-sun50iw1p1-with-$PLATFORM-dtb.bin.tmp
$SUNXI_PACK_TOOLS/update_uboot $BUILD/u-boot-sun50iw1p1-with-$PLATFORM-dtb.bin.tmp $BUILD/sys_config_uboot.bin
mv $BUILD/u-boot-sun50iw1p1-with-$PLATFORM-dtb.bin.tmp $BUILD/u-boot-sun50iw1p1-with-$PLATFORM-dtb.bin
$SUNXI_PACK_TOOLS/merge_uboot $UBOOT/u-boot-sun50iw1p1.bin $BLOBS/bl31.bin $BUILD/u-boot-sun50iw1p1-secure-with-$PLATFORM-dtb.bin.tmp secmonitor
$SUNXI_PACK_TOOLS/merge_uboot $BUILD/u-boot-sun50iw1p1-secure-with-$PLATFORM-dtb.bin.tmp $BLOBS/scp.bin $BUILD/u-boot-sun50iw1p1-secure-with-$PLATFORM-dtb.bin.tmp2 scp
$SUNXI_PACK_TOOLS/update_uboot_fdt $BUILD/u-boot-sun50iw1p1-secure-with-$PLATFORM-dtb.bin.tmp2 $BUILD/a64-$PLATFORM-uboot.dtb $BUILD/u-boot-sun50iw1p1-secure-with-$PLATFORM-dtb.bin.tmp3
$SUNXI_PACK_TOOLS/update_uboot $BUILD/u-boot-sun50iw1p1-secure-with-$PLATFORM-dtb.bin.tmp3 $BUILD/sys_config_uboot.bin
mv $BUILD/u-boot-sun50iw1p1-secure-with-$PLATFORM-dtb.bin.tmp3 $BUILD/u-boot-sun50iw1p1-secure-with-$PLATFORM-dtb.bin
echo "Done - created $BUILD/u-boot-sun50iw1p1-secure-with-$PLATFORM-dtb.bin"

