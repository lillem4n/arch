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

# Add sudo group to sudoers file
echo "%sudo ALL=(ALL) ALL" >> /etc/sudoers

# Add real user
useradd -m -g users -G sudo,docker lilleman

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

# Autostart i3 on login on first tty
echo "" >> /home/lilleman/.bash_profile
echo "# Start X11 (i3) on login to tty1" >> /home/lilleman/.bash_profile
echo "if [ -z \"\$DISPLAY\" ] && [ \"\$(fgconsole)\" -eq 1 ]; then" >> /home/lilleman/.bash_profile
echo "  exec startx" >> /home/lilleman/.bash_profile
echo "fi" >> /home/lilleman/.bash_profile

# Make sure bash profile is owned by the new user
chown lilleman:users /home/lilleman/.bash_profile

# Set Swedish keyboard layout in X11
echo "Section \"InputClass\"" > /etc/X11/xorg.conf.d/10-keyboard.conf
echo "	Identifier \"system-keyboard\"" >> /etc/X11/xorg.conf.d/10-keyboard.conf
echo "	MatchIsKeyboard \"on\"" >> /etc/X11/xorg.conf.d/10-keyboard.conf
echo "	Option \"XkbLayout\" \"se\"" >> /etc/X11/xorg.conf.d/10-keyboard.conf
echo "	Option \"XkbModel\" \"pc105\"" >> /etc/X11/xorg.conf.d/10-keyboard.conf
echo "EndSection" >> /etc/X11/xorg.conf.d/10-keyboard.conf

# Enable network manager to make nm-applet work
#systemctl enable NetworkManager

# Exit chroot env
exit
