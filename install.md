# Connecting to wifi during installation
iwctl station wlan0 connect SSID

# Partitions
boot 512M tpye EF00 (EFI)
swap 8G type 8200 (SWAP)
root 100% type 8300 (ext4)

# Encryption
cryptsetup luksFormat /dev/nvme0n1p3
cryptsetup open /dev/nvme0n1p3 cryptroot

# Format
mkfs.vfat -F32 /dev/nvme0n1p1

mkswap /dev/nvme0n1p2
swapon /dev/nvme0n1p2

mkfs.ext4 /dev/mapper/cryptroot

# Mount
mount /dev/mapper/cryptroot /mnt
mkdir /mnt/boot
mount /dev/nvme0n1p1 /mnt/boot

# Install essentials
pacstrap /mnt base base-devel linux linux-firmware

# Generate fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Chroot
arch-chroot /mnt

# Timezone
locale-gen

ln -sf /usr/share/zoneinfo/US/Central /etc/localtime

hwclock --systohc --utc

# Hostname
echo "archtop" > /etc/hostname

# Install system packages
pacman -S networkmanager vim vi nano git sudo zsh zsh-completions sbctl

# Edit /etc/mkinitcpio.conf add encrypt to HOOKS
HOOKS=(base udev autodetect keyboard keymap consolefont modconf block encrypt filesystems fsck)

# Regenerate initramfs
mkinitcpio -P linux

# Set root password
passwd

# Add user
useradd -m -G wheel -s /bin/zsh jscalera
passwd jscalera

# Create file in /etc/sudoers.d/jscalera
```
jscalera ALL=(ALL) NOPASSWD: ALL
```

# Install bootloader (systemd-boot)
bootctl --path=/boot install

# Create /boot/loader/loader.conf
```
default arch
timeout 3
```

# Create /boot/loader/entries/arch.conf
```
title Arch Linux
linux /vmlinuz-linux
initrd /initramfs-linux.img
options cryptdevice=/dev/nvme0n1p3:cryptroot root=/dev/mapper/cryptroot rw
```

# Create and enroll secure boot keys
sbctl create-keys
sbctl enroll-keys -m

sbctl sign -s -o /usr/lib/systemd/boot/efi/systemd-bootx64.efi.signed /usr/lib/systemd/boot/efi/systemd-bootx64.efi
sbctl sign -s /boot/EFI/systemd/systemd-bootx64.efi
sbctl sign -s /boot/vmlinuz-linux
sbctl sign -s /boot/EFI/BOOT/BOOTX64.EFI

