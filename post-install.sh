#!/usr/bin/env bash

read -rep "Host name     > " IN_HOSTNAME
read -rep "User name     > " IN_UNAME
IFS="/" read -rep "Netctl IP addr> " -a IN_ADDR
echo "(Note: separate package names with a command and space)"
IFS=", " read -rep "Extra packages> " -a IN_PACKAGES

NETADDR="${IN_ADDR[0]}/24"
(( ${#IN_ADDR[@]} > 1 )) && NETADDR="${IN_ADDR[0]}/${IN_ADDR[1]}"

while read -ru 10 ln; do
	IFS=" " read -ra parsed <<< "$ln"
	if (( ${#parsed[@]} > 4 )) && [[ "${parsed[1]}" != "lo:" ]]; then
		NETDEV="${parsed[1]::-1}"
		break
	fi
done 10< <(ip link show)

echo "$IN_HOSTNAME" > /etc/hostname
cat << NETCFG > "/etc/netctl/$NETDEV"
Description="netctl config ooooof"
Interface=$NETDEV
Connection=ethernet
IP=static
Address=("$NETADDR")
Gateway="192.168.88.253"
DNS=("192.168.88.10","1.1.1.1")
NETCFG
ip link set "$NETDEV" down
netctl start "$NETDEV"
netctl enable "$NETDEV"
pacman -S ldns openssh git "${IN_PACKAGES[@]}" --noconfirm
systemctl enable sshd.service
systemctl start sshd.service
echo "Type in a password for ROOT"
passwd
useradd -mg wheel -s /bin/bash "$IN_UNAME"
echo "Type in a password for $IN_UNAME"
passwd "$IN_UNAME"
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers
su "$IN_UNAME"

echo "alias ll=\"ls -l\""       >  .bash_profile
echo "alias cd..=\"cd ..\""     >> .bash_profile
echo "alias cd-=\"cd $OLDPWD\"" >> .bash_profile
echo "alias aur=\". .aur.sh\""  >> .bash_profile
