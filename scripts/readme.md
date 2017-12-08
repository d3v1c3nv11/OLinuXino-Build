# A64-OLinuXino Build Instructions

## Linux

### 1. Getting source code and helper scripts
	
```bash
cd ~/
git clone https://github.com/OLIMEX/DIY-LAPTOP
cd DIY-LAPTOP/SOFTWARE/A64-TERES/
```
### 2. Setup toolchain
```bash
	sudo apt install gcc-aarch64-linux-gnu
        sudo apt install gcc-4.7-arm-linux-gnueabihf
	sudo apt install kpartx bsdtar mtools
```

### 3. Cross-compile sources

#### Linux
```bash
cd linux-a64
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- olimex_teres1_defconfig #a64-Teres
```
or
```bash
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- olimex_a64olinuxino_defconfig #A64-OLinuXino
```
```bash
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- LOCALVERSION= clean
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j4 LOCALVERSION= Image
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j4 LOCALVERSION= modules
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j4 LOCALVERSION= modules_install  INSTALL_MOD_PATH=out INSTALL_MOD_STRIP=1
```
#### Allwinner Pack Tools 
```bash
cd ../
make -C sunxi-pack-tools
```
#### U-Boot
```bash
cd scripts/
./build_uboot.sh teres1 #A64-Teres
```
or 
```bash
./build_uboot.sh a64olinuxino #A64-OLinuXino
```
### 4. Helper Scripts
## Ramdisk

Either make one with the steps below or download one from some other place.
Make sure the initrd is for aarch64.

### Get Busybox tree

```bash
cd ../
git clone --depth 1 --branch 1_24_stable --single-branch git://git.busybox.net/busybox busybox
```

### Configure and build Busybox

Build a static busybox for aarch64. Start by copying the `blobs/a64_config_busybox`
file to `.config` of your Busybox folder.

```bash
cp blobs/a64_config_busybox busybox/.config
cd busybox 
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j4 oldconfig
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j4
```

### Make initrd.gz

Use the provided `make_initrd.sh` script to create a simple initrd based on
the busybox binary compiled earlier.

```bash
cd ../scripts
./make_initrd.sh
```
### Create bootable image

Create kernel tarball :
```bash 
./make_kernel_tarball.sh teres1 . ../linux-a64 #This will produce file named linux-a64-xx.yy.zz.tar.xz 
```
or
```bash 
./make_kernel_tarball.sh a64olinuxino . ../linux-a64 #This will produce file named linux-a64-xx.yy.zz.tar.xz
```

Create simple image structure :
```bash
sudo ./make_simpleimage.sh simple.img 1000 linux-a64-3.10.104-1.tar.xz teres1
sudo xz simple.img
```
or
```bash
sudo ./make_simpleimage.sh simple.img 1000 linux-a64-3.10.104-1.tar.xz a64olinuxino
sudo xz simple.img
```

Build bootable image :
A64-Teres
```bash
sudo ./build_image.sh simple.img.xz linux-a64-3.10.104-1.tar.xz xenial teres1
```
or A64-OlinuXino
```bash
sudo ./build_image.sh simple.img.xz linux-a64-3.10.104-1.tar.xz xenial a64olinuxino
```

if everything is successfully acomplished this command will create file named :
xenial-<platform>-bspkernel-<date>.img
use dd to write this image to Sd Card : 
```bash
dd if=xenial-<platform>-bspkernel-<date>.img of=/dev/sdX bs=1M
```

After first boot you will able to login with : 
user: olimex
pass: olimex

Connection to internet can be enabled using nmtui tool:
```bash
nmtui
```

Feel free to install everything you want, for ex. Graphical desktop : 
```bash
./install_desktop.sh mate #will install mate 
```
