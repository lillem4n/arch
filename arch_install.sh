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
pacstrap /mnt \
 base base-devel \ # Base packages for Arch
 grub-efi-x86_64 efibootmgr \ # UEFI stuff
 dialog \ # A tool to display dialog boxes from shell scripts
 wpa_supplicant \ # Needed for wifi-menu to work with WPA wireless networks
 xorg xorg-xinit \ # Xorg (X11)
 i3 i3lock i3status \ # i3 Window Manager
 dmenu \ # dmenu used to launch applications in i3
 bash-completion \ # Autocompletion in bash, who can live without it?
 openssh \
 nano \ # The text editor that dont need research to exit
 git \ # git version management
 terminator \ # An awesome terminal handler to use in i3
 xterm \ # Fallback terminal
 leafpad \ # Great notepad, minimalistic
 chromium \
 thunar thunar-volman \ # File manager, good stuff
 atom \ # Hackable code editor
 pulseaudio pulseaudio-alsa \ # Audio stuff
 firefox \
 wget \
 docker \ # Containerization software
 ttf-dejavu \ # True type fonts (only very basic low res bitmap fonts are installed by default)
 ntp # Network Time Protocol - for syncronizing the clock
# networkmanager \
# networkmanager-openvpn \
# network-manager-applet

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
