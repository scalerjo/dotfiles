# Arch Linux Installation Guide

## Connecting to wifi during installation
```bash
iwctl device list
iwctl station wlan0 scan
iwctl station wlan0 get-networks
iwctl station wlan0 connect SSID
```

## Partitions
- boot 512M type EF00 (EFI)
- swap 16G type 8200 (SWAP) equal to amount of RAM
- root 100% type 8300 (ext4)

## Encryption
```bash
cryptsetup luksFormat /dev/nvme0n1p3
cryptsetup open /dev/nvme0n1p3 cryptroot
```

## Format
```bash
mkfs.vfat -F32 /dev/nvme0n1p1

mkswap /dev/nvme0n1p2
swapon /dev/nvme0n1p2

mkfs.ext4 /dev/mapper/cryptroot
```

## Mount
```bash
mount /dev/mapper/cryptroot /mnt
mkdir /mnt/boot
mount /dev/nvme0n1p1 /mnt/boot
```

## Install essentials
```bash
pacstrap /mnt base base-devel linux linux-firmware
```

## Generate fstab
```bash
genfstab -U /mnt >> /mnt/etc/fstab
```

## Chroot
```bash
arch-chroot /mnt
```

## Install system packages
```bash
pacman -S networkmanager vim vi nano git sudo zsh zsh-completions sbctl
```

## Timezone
- edit `/etc/locale.gen` and un-comment `en_US.UTF-8 UTF-8`
```bash
locale-gen

ln -sf /usr/share/zoneinfo/US/Central /etc/localtime

hwclock --systohc --utc
```

## Hostname
```bash
echo "archtop" > /etc/hostname
```

## Edit /etc/mkinitcpio.conf add encrypt to HOOKS
```
HOOKS=(base udev autodetect keyboard keymap consolefont modconf block encrypt filesystems fsck)
```

## Regenerate initramfs
```bash
mkinitcpio -P linux
```

## Set root password
```bash
passwd
```

## Add user
```bash
useradd -m -G wheel -s /bin/zsh jscalera
passwd jscalera
```

## Create file in /etc/sudoers.d/jscalera
```
jscalera ALL=(ALL) NOPASSWD: ALL
```

## Install bootloader (systemd-boot)
```bash
bootctl --path=/boot install
```

## Create /boot/loader/loader.conf
```
default arch
timeout 3
```

## Create /boot/loader/entries/arch.conf
```
title Arch Linux
linux /vmlinuz-linux
initrd /initramfs-linux.img
options cryptdevice=/dev/nvme0n1p3:cryptroot root=/dev/mapper/cryptroot rw
```

## Create and enroll secure boot keys
```bash
sbctl create-keys
sbctl enroll-keys -m

sbctl sign -s -o /usr/lib/systemd/boot/efi/systemd-bootx64.efi.signed /usr/lib/systemd/boot/efi/systemd-bootx64.efi
sbctl sign -s /boot/EFI/systemd/systemd-bootx64.efi
sbctl sign -s /boot/vmlinuz-linux
sbctl sign -s /boot/EFI/BOOT/BOOTX64.EFI
```

## Enable services
```bash
systemctl enable NetworkManager
```

## Exit chroot
```basb
exit
```

## Unmount and reboot
```bash
umount -R /mnt
reboot
```

# Post Installation

## Clone this repo
```bash
git clone https://github.com/scalerjo/dotfiles.git
mv dotfiles ~/.config
```

## Install yay
```base
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
```

## Install packages
```bash
yay -S --needed --noconfirm - < ~/.config/pkglist.txt
```

## Create slick greeter config
- edit `/etc/lightdm/lightdm.conf` set `greeter-session=lightdm-slick-greeter` and `user-session=i3`
- edit `/etc/lightdm/slick-greeter.conf`
```
[Greeter]
show-power = true
show-quit = true
background = /usr/share/backgrounds/main.jpg
```
- `systemctl enable lightdm`

## Copy polybar config example
- `cp ~/.config/polybar/polybar.config.example ~/.config/polybar/polybar.config` and edit as needed

## Create .zshenv
- `echo "export ZDOTDIR=$HOME/.config/zsh" > ~/.zshenv`

## Install nvm
- `curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash`
- Append the following to `~/.zshenv`
```
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
```

## Install lang servers
- `~/.config/scripts/install-lang-servers.sh`
