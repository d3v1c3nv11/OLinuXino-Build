
SRCLINUX="linux-a64"
PLATFORM="$1"
VERSION="3.10.104-4"

if [ "$(id -u)" -ne "0" ]; then
	echo "This script requires root."
	exit 1
fi
if [ -z "$PLATFORM" ]; then
	echo "Usage: sudo ./build_image.sh <platform>"
	exit 1
fi

echo "Compile Linux Kernel and modules for $PLATFORM ..."
cd ../linux-a64
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- olimex_"$PLATFORM"_defconfig
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- LOCALVERSION= clean
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j4 LOCALVERSION= Image
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j4 LOCALVERSION= modules
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j4 LOCALVERSION= modules_install  INSTALL_MOD_PATH=out INSTALL_MOD_STRIP=1
echo "Make Allwiner Pack Tools"
cd ../
make -C sunxi-pack-tools
echo "Make U-Boot for $PLATFORM"
cd scripts/
./build_uboot.sh $PLATFORM
echo "Getting BusyBox"
cd ../
git clone --depth 1 --branch 1_24_stable --single-branch git://git.busybox.net/busybox busybox
echo "Configure and build Busybox"
cp blobs/a64_config_busybox busybox/.config
cd busybox 
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j4 oldconfig
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j4
echo Make initrd.gz
cd ../scripts
./make_initrd.sh
echo Create bootable image
PWD=$(pwd)
./make_kernel_tarball.sh $PLATFORM $PWD ../linux-a64
TARBALL=$(ls linux-a64-*.tar.xz)
echo ./make_simpleimage.sh simple.img 1000 $PWD/$TARBALL $PLATFORM
./make_simpleimage.sh simple.img 1000 $PWD/$TARBALL $PLATFORM
xz simple.img
echo Packing image...
./pack_image.sh simple.img.xz $PWD/$TARBALL xenial $PLATFORM

rm -f initrd.gz
rm -f linux-a64-$VERSION.tar.xz
rm -rf build
