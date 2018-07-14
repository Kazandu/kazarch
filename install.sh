#!/usr/bin/env bash

read -rep "IP addr       > " IN_ADDR
read -rep "Gateway addr  > " IN_GATEWAY
read -rep "Broadcast addr> " IN_BCAST

while read -ru 10 ln; do
	IFS=" " read -ra parsed <<< "$ln"
	if (( ${#parsed[@]} > 4 )) && [[ "${parsed[1]}" != "lo:" ]]; then
		NETDEV="${parsed[1]::-1}"
		break
	fi
done 10< <(ip link show)

loadkeys de-latin1
ip link set "$NETDEV" up
ip addr add "$IN_ADDR" broadcast "$IN_BCAST" dev "$NETDEV"
ip route add default via "$IN_GATEWAY"
gdisk /dev/sda << EOCMD
n
128
-3M

ef02
n
1



w
y
q
EOCMD
mkfs.ext4 /dev/sda1
mount /dev/sda1 /mnt
mkdir /mnt/kazarch
cp /kazarch/post-install.sh /mnt/kazarch
pacman -S archlinux-keyring --noconfirm
pacstrap /mnt base base-devel intel-ucode
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt << ENDCFG
ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime
hwclock --systohc
echo "en_US.UTF-8" >> /etc/locale.gen
locale-gen
echo "KEYMAP=de-latin1" > /etc/vconsole.conf
mkinitcpio -p linux
pacman -S grub --noconfirm
grub-mkconfig -o /boot/grub/grub.cfg
grub-install /dev/sda
exit
ENDCFG
reboot