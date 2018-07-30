#!/usr/bin/env bash
RED='\033[0;31m'
LIGHTMAG='\e[95m'
REDBG='\e[41m'
CYAN='\e[36m'
GREEN='\e[32m'
NC='\033[0m'
NCBG='\e[49m'
printf "Welcome to the ${CYAN}KazArch${NC} install wizard!\n
In Order to run ${CYAN}KazArch${NC} we need to set some configurations:\n"

net_config () {
	read -rep "IP address       > " IN_ADDR
	read -rep "Gateway address  > " IN_GATEWAY
	read -rep "Broadcast address> " IN_BCAST

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
}
read -p "Do you have DHCP active in your Network (y/n)?" netchoice
case "$netchoice" in 
  y|Y ) 
  	IFS=", " read -ra arr <<< "$(drill kazandu.moe)"
	if [[ "${arr[1]}" != "rcode: NOERROR" ]]; then
    		echo "Seems like Internet isn't working properly, starting Network config..."
		net_config
	else
    		echo "Skipping network configuration..."
	fi ;;
  n|N ) 
	net_config ;;
esac
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
mkdir /mnt/kazarch
cp /kazarch/post-install.sh /mnt/kazarch
#using this to prevent it from rebooting too fast until its final, if its finished just remove the prompt and put the
#reboot i commented out down there back in 
read -p "[PROMPT FOR TESTING: Reboot (y/n)?]" rebootchoice
case "$rebootchoice" in 
  y|Y ) 
  	reboot;;
  n|N ) 
  	exit;;
esac
#reboot
