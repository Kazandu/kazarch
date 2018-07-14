#!/bin/sh

startdir=$PWD

echo "Making a temporary location for packages..."
mkdir /tmp/aur_$1

echo "Cloning package from AUR..."
git clone https://aur.archlinux.org/$1.git /tmp/aur_$1 &>/dev/null

if [ -f /tmp/aur_$1/PKGBUILD ]; then
	echo "Installing package"
	cd /tmp/aur_$1
	makepkg -si
else
	echo "Invalid package."
fi

echo "Removing temporary location..."
rm -rf /tmp/aur_$1

cd $startdir
