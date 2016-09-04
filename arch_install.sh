# The first commented out commands must be done before this script is ran:

# Setup wifi, not needed if DHCP ethernet is present
#wifi-menu

# Disk partition
#cgdisk /dev/sda
#1 100M EFI partition # Hex code ef00
#2 250M Boot partition # Hex code 8300
#3 4G Swap # Hex code # Hex code 8200
#4 100% System partition # Hex code 8300

# Create filesystems
mkfs.vfat -F32 /dev/sda1
mkfs.ext2 /dev/sda2
mkswap /dev/sda3
mkfs.ext4 /dev/sda4

# Mount the new system
mount /dev/sda4 /mnt
swapon /dev/sda3
mkdir /mnt/boot
mount /dev/sda2 /mnt/boot
mkdir /mnt/boot/efi
mount /dev/sda1 /mnt/boot/efi

# Install the system
# Including some wifi stuff, xorg, wm and more
pacstrap /mnt base \
 base-devel \
 grub-efi-x86_64 \
 efibootmgr \
 dialog \
 wpa_supplicant \
 xorg xorg-xinit \
 i3 \
 i3lock \
 i3status \
 dmenu \
 bash-completion \
 openssh \
 nano \
 git \
 terminator \
 xterm \
 leafpad \
 chromium \
 thunar \
 thunar-volman \
 atom \
 pulseaudio \
 pulseaudio-alsa

# Setup fstab
genfstab -pU /mnt >> /mnt/etc/fstab

# Set hostname
echo tiny > /mnt/etc/hostname

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

# Copy second install step into chroot env
cp ./arch_install2.sh /mnt/arch_install2.sh

# Run second install step inside the chroot
arch-chroot /mnt /arch_install2.sh

# Reboot system when done
reboot
