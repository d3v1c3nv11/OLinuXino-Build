# WORK IN PROGRESS >>>>>>>>> OLinuXino Build Instructions

## UBUNTU 16.04.3 LTS

### 1. Getting source code and helper scripts
	
```bash
cd ~/
git clone https://github.com/d3v1c3nv11/OLinuXino-Build.git
cd OLinuXino-Build
```
### 2. Setup toolchain
```bash
	sudo apt install gcc-aarch64-linux-gnu
        sudo apt install gcc-4.7-arm-linux-gnueabihf
	sudo apt install kpartx bsdtar mtools
```

### 3. Build bootable image 

```bash
sudo ./build-image.sh <platform>
```
Suported platforms:
* teres1
* a64olinuxino


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
