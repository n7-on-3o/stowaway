# Arch Linux post install

Install Arch with archinstall:

1. Manual partition. 4 GiB /boot, rest btrfs with @, @home, @log, @cache
2. LUKS encryption for root partition
3. systemd-boot bootloader UKI enabled
4. Minimal install (no DE or WM)
5. Add a text editor (I like micro)

## 1. Basics
### 1.1. Install packages
```bash
./install.sh
```
### 1.2. Add some color to pacman
```bash
sudo micro /etc/pacman.conf
````
add these lines:
```
Color
ILoveCandy
VerbosePkgLists
ParallelDownloads=5
```
### 1.3. Cleanup package cache
install pacman-contrib package
```bash
sudo pacman -S pacman-contrib
```
edit pacman-contrib
```bash
sudo micro /etc/conf.d/pacman-contrib
```
to look like
```
PACCACHE_ARGS="-k2 -u"
```
enable the cleanup timer
```bash
sudo systemctl enable --now paccache.timer
```
## 2. Dracut
transition from mkinitcpio to dracut
### 2.1. Install dracut
```bash
sudo pacman -S dracut cpio
```
### 2.2. Create dracut config
```
sudo micro /etc/dracut.conf.d/10-luks.conf
```
add this content
```
# UKI and Module Settings
uefi="yes"
hostonly="yes"
uefi_stub="/usr/lib/systemd/boot/efi/linuxx64.efi.stub"
uefi_splash_image="/usr/share/systemd/bootctl/splash-arch.bmp"
compress="zstd"

# Kernel Command Line
kernel_cmdline+=" rd.luks.uuid=d2f6bb0d-f744-4f07-99f4-1d0f3a7f06c1 root=UUID=51a5006d-bd75-4e15-8ba7-56adba4fe872 rootfstype=btrfs rootflags=compress=zstd:3,subvol=@ rw splash quiet"
```
```bash
lsblk -f #run this to find the uuids
```
if using nvidia-open-dkms
```
sudo micro /etc/dracut.conf.d/20-nvidia.conf
```
add this content
```
force_drivers+=" nvidia nvidia_modeset nvidia_uvm nvidia_drm "

# Kernel Command Line
kernel_cmdline+=" rd.driver.blacklist=nouveau modprobe.blacklist=nouveau nvidia-drm.modeset=1 "
```
### 2.3. Create kernel-install config
```
sudo micro /etc/dracut.conf.d/10-luks.conf
```
add this content
```
layout=uki
uki_generator=dracut
initrd_generator=dracut
```
### 2.4. Add kernel-install hooks
we need to replace two dracut (or mknintcpio) hooks with kernel-install ones
```bash
micro /etc/pacman.d/hooks/60-kernel-remove.hook
```
add this
```
[Trigger]
Type = Path
Operation = Remove
Target = usr/lib/modules/*/pkgbase

[Action]
Description = Removing UKI and kernel entries via kernel-install...
When = PreTransaction
Exec = /usr/bin/bash -c "while read -r p; do V=$(basename $(dirname $p)); /usr/bin/kernel-install remove $V; done"
NeedsTargets
```
and
```bash
micro /etc/pacman.d/hooks/90-kernel-install.hook 
```
add this
```
[Trigger]
Type = Path
Operation = Install
Operation = Upgrade
Operation = Remove
Target = usr/lib/dracut/*
Target = usr/lib/firmware/*
Target = usr/src/*/dkms.conf
Target = usr/lib/systemd/systemd
Target = usr/bin/cryptsetup
Target = usr/bin/lvm

[Trigger]
Type = Path
Operation = Install
Operation = Upgrade
Target = usr/lib/modules/*/vmlinuz
Target = usr/lib/modules/*/pkgbase

[Trigger]
Type = Package
Operation = Install
Operation = Upgrade
Target = dracut

[Action]
Description = Rebuilding all UKIs via kernel-install...
When = PostTransaction
Exec = /usr/bin/bash -c "while read -r p; do V=$(basename $(dirname $p)); /usr/bin/kernel-install add $V /usr/lib/modules/$V/vmlinuz; done"
NeedsTargets
```
### 2.5. Cleanup and test
remove mkinitcpio and its configuration files
```bash
sudo pacman -Rsn mkinitcpio
sudo rm -rf /etc/mkinitcpio.*
```
remove dracut hooks
```bash
sudo ln -s /dev/null /etc/pacman.d/hooks/60-dracut-remove.hook
sudo ln -s /dev/null /etc/pacman.d/hooks/90-dracut-install.hook
```
force rebuild the uki image
```bash
sudo kernel-install -v add $(uname -r) /usr/lib/modules/$(uname -r)/vmlinuz
```
and reboot
## 3. Snapper
### 3.1. Install snapper
```bash
sudo pacman -S snapper snap-pac
```
### 3.2. Create @snapshots subvolume
```bash
#your luks uuid will be different
sudo mount -o subvolid=5 /dev/mapper/luks-241758c6-9945-455e-abc5-5956aabbf663 /mnt
sudo btrfs subvolume create /mnt/@snapshots
sudo umount /mnt
```
edit your fstab to include the newly created subvolume
```bash
sudo micro /etc/fstab
```
again, your UUID will be different
```
UUID=170cdcab-a15b-4f5b-a55d-512f78b22ed9       /.snapshots btrfs       rw,relatime,compress=zstd:3,ssd,space_cache=v2,subvol=/@snapshots       0 0
```
create snapper config for root
```bash
sudo snapper -c root create-config /
```
replace the auto-created directory with a subvolume
```
sudo btrfs subvolume delete /.snapshots
sudo mkdir /.snapshots
sudo systemctl daemon-reload
sudo mount /.snapshots
```
### 3.3. Add systemd-boot support
install systemd-boot-snapper-tools from github
```bash

```
edit /etc/defaultgit clone https://github.com/n7-on-3o/systemd-boot-snapper-tools.git
cd systemd-boot-snapper-tools
to test everything, create a snapshot
```bash
sudo snapper -c root create -d "1st snapshot"
```
check that /boot/loader/entries has been correctly updated and reboot
### 3.4. Cleanup snapshots
edit snapper config
```bash
sudo micro /etc/snapper/configs/root
```
to something like
```
# users and groups allowed to work with config
ALLOW_USERS="<your user>"
ALLOW_GROUPS="wheel"

# run daily number cleanup
NUMBER_CLEANUP="yes"

# limit for number cleanup
NUMBER_MIN_AGE="1800"
NUMBER_LIMIT="10"
NUMBER_LIMIT_IMPORTANT="5"


# create hourly snapshots
TIMELINE_CREATE="yes"

# cleanup hourly snapshots after some time
TIMELINE_CLEANUP="yes"

# limits for timeline cleanup
TIMELINE_MIN_AGE="1800"
TIMELINE_LIMIT_HOURLY="5"
TIMELINE_LIMIT_DAILY="7"
TIMELINE_LIMIT_WEEKLY="0"
TIMELINE_LIMIT_MONTHLY="0"
TIMELINE_LIMIT_QUARTERLY="0"
TIMELINE_LIMIT_YEARLY="0"
```
enable the cleanup timers
```bash
sudo systemctl enable --now snapper-timeline.timer
sudo systemctl enable --now snapper-cleanup.timer
```
