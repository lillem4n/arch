# Boot Arch USB

# Load Swedish keyboard
loadkeys sv-latin1

# List drives and figure out what drive to use
lsblk

# I'm assuming /dev/nvme0p1 as the drive to use

# Clear previous stuff on disk:
gdisk /dev/nvme0n1

# Then press "x" for advanced options, then "z" for ZAP! to erase everything. Answer Y on all questions

# Now partition disk
cgdisk /dev/nvme0n1

# We need:
# 1Gb boot (type EF00, name "boot")
# SWAP (type 8200, name "swap", same size as your RAM)
# root (type 8300, name "root", the rest of the disk)

# write and then quit

# Reboot on the USB again to make sure that the drive is reread correctly

# After boot, load Swedish keyboard again
loadkeys sv-latin1

# Assign filesystems to the partitions
mkfs.fat -F32 /dev/nvme0n1p1
mkswap /dev/nvme0n1p2
swapon /dev/nvme0n1p2
mkfs.ext4 /dev/nvme0n1p3

# Mount our new partitions
mount /dev/nvme0n1p3 /mnt
mkdir /mnt/boot
mount /dev/nvme0n1p1 /mnt/boot

# Sort mirrorlist (takes minutes!!)
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
sed -i 's/^#Server/Server/' /etc/pacman.d/mirrorlist.backup
rankmirrors -n 6 /etc/pacman.d/mirrorlist.backup > /etc/pacman.d/mirrorlist

# Install base system
pacstrap -i /mnt base base-devel dialog xorg xorg-xinit i3-wm i3status dmenu bash-completion openssh nano xterm leafpad chromium thunar thunar-volman firefox wget ttf-dejavu intel-ucode

# Generate fstab
genfstab -pU /mnt >> /mnt/etc/fstab

# add ",discard" to the options-column for the swap if it is supported by your drive. It is good stuff if it is. :)

# Set hostname
echo teve > /mnt/etc/hostname

# Set locale
echo LANG=en_US.UTF-8 >> /mnt/etc/locale.conf
echo LANGUAGE=en_US >> /mnt/etc/locale.conf
echo LC_ALL=C >> /mnt/etc/locale.conf
echo "en_US.UTF-8 UTF-8" > /mnt/etc/locale.gen # The single arrow empties whatever was in this file before
echo "sv_SE.UTF-8 UTF-8" >> /mnt/etc/locale.gen

# Swedish keymap in console
echo KEYMAP=sv-latin1 > /mnt/etc/vconsole.conf

# Make X run without being root
echo allowed_users=anybody >> /mnt/etc/X11/Xwrapper.config
echo needs_root_rights=yes >> /mnt/etc/X11/Xwrapper.config

# Chroot into the new environment
arch-chroot /mnt bash

# Install bootloader
bootctl install

# Setup bootloader configuration file
echo "title Arch Linux" > /boot/loader/entries/arch.conf
echo "linux /vmlinuz-linux" >> /boot/loader/entries/arch.conf
echo "initrd /intel-ucode.img" >> /boot/loader/entries/arch.conf
echo "initrd /initramfs-linux.img" >> /boot/loader/entries/arch.conf
echo -n "options root=PARTUUID=" >> /boot/loader/entries/arch.conf
echo -n `blkid -s PARTUUID -o value /dev/nvme0n1p3` >> /boot/loader/entries/arch.conf
echo " rw" >> /boot/loader/entries/arch.conf

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
useradd -m -g users -G sudo lilleman

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

# Set autologin on tty1 upon boot
mkdir /etc/systemd/system/getty@tty1.service.d
echo "[Service]" >> /etc/systemd/system/getty@tty1.service.d/override.conf
echo "ExecStart=" >> /etc/systemd/system/getty@tty1.service.d/override.conf
echo "ExecStart=-/usr/bin/agetty --autologin lilleman --noclear %I $TERM" >> /etc/systemd/system/getty@tty1.service.d/override.conf

# Make sure networking is started and set up DHCP on wired interface
systemctl enable systemd-networkd
echo "[Match]" > /etc/systemd/network/eno1.network
echo "Name=eno1" >> /etc/systemd/network/eno1.network
echo "" >> /etc/systemd/network/eno1.network
echo "[Network]" >> /etc/systemd/network/eno1.network
echo "DHCP=ipv4" >> /etc/systemd/network/eno1.network


# Exit chroot env
exit

# Reboot system
reboot
