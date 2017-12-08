#!/bin/sh

set -e


PLATFORM="$1"
DEST="$2"
if [ -z "$DEST" ]; then
	echo "Usage: $0 <destination-folder> [linux-folder] [extra-version]"
	exit 1
fi
if [ -z "$PLATFORM" ];then
	PLATFORM="teres1"
fi

LINUX="../linux-a64"

if [ -n "$2" ]; then
	LINUX="$3"
fi

EXTRAVERSION="$4"

echo "Using Linux from $LINUX ..."

TEMP=$(mktemp -d)
mkdir $TEMP/boot

cleanup() {
	if [ -d "$TEMP" ]; then
		rm -rf "$TEMP"
	fi
}
trap cleanup EXIT

./install_kernel.sh "$TEMP/boot" "$LINUX" "$PLATFORM"
./install_kernel_modules.sh "$TEMP" "$LINUX"
./install_kernel_headers.sh "$TEMP" "$LINUX"

# Use uEnv.txt.in so we do not overwrite customizations on next update.
mv "$TEMP/boot/uEnv.txt" "$TEMP/boot/uEnv.txt.in"

if [ -z "$EXTRAVERSION" -a -e "$LINUX/.version" ]; then
	EXTRAVERSION=$(cat "$LINUX/.version")
else
	EXTRAVERSION=$(date +%s)
fi

VERSION="$(ls -1tr $TEMP/lib/modules/|tail -n1)-$EXTRAVERSION"

echo "Building $VERSION ..."
tar -C "$TEMP" -cJ --owner=0 --group=0 --xform='s,./,,' -f "$DEST/linux-a64-$VERSION.tar.xz" .

echo "Done - $DEST/linux-a64-$VERSION.tar.xz"
