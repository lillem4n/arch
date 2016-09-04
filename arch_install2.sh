############!!!!#############
## Run only within a chroot #
############!!!!#############

# Generate locales
locale-gen

# Setup system clock
ln -s /usr/share/zoneinfo/Europe/Stockholm /etc/localtime
hwclock --systohc --utc

# Add sudo group
groupadd sudo

# Add real user
useradd -m -g users -G sudo lilleman

# Configure mkinitcpio with modules
perl -pi -e 's/MODULES=""/MODULES="ext4"/g' /etc/mkinitcpio.conf

# Regenerate initrd image
mkinitcpio -p linux

# Setup grub
grub-install
grub-mkconfig -o /boot/grub/grub.cfg

# Set password for root
echo "Root password:"
passwd

# Set password for the new user
echo "User password:"
passwd lilleman

# Set i3 to xinit
echo "exec i3" > /home/lilleman/.xinitrc

# Change .xinitrc ownership to our new user
chown lilleman:users /home/lilleman/.xinitrc

# Set Swedish keyboard layout in X11
echo "Section \"InputClass\"" > /etc/X11/xorg.conf.d/10-keyboard.conf
echo "	Identifier \"system-keyboard\"" >> /etc/X11/xorg.conf.d/10-keyboard.conf
echo "	MatchIsKeyboard \"on\"" >> /etc/X11/xorg.conf.d/10-keyboard.conf
echo "	Option \"XkbLayout\" \"se\"" >> /etc/X11/xorg.conf.d/10-keyboard.conf
echo "	Option \"XkbModel\" \"pc105\"" >> /etc/X11/xorg.conf.d/10-keyboard.conf
echo "EndSection" >> /etc/X11/xorg.conf.d/10-keyboard.conf

# Exit chroot env
exit

