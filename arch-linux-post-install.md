# Arch Linux post install

Install Arch with archinstall:

1. Manual partition. 4 GiB /boot, rest btrfs with @, @home, @log, @cache
2. LUKS encryption for root partition
3. Limine bootloader UKI enabled
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
### 2.2. Create dracut.conf
```
sudo micro /etc/dracut.conf.d/dracut.conf
```
add this content
```
# UKI and Module Settings
uefi="yes"
add_dracutmodules+=" systemd dracut-systemd crypt btrfs rootfs-block "
hostonly="yes"

# Compression & Visuals
compress="zstd"
uefi_splash_image="/usr/share/systemd/bootctl/splash-arch.bmp"

# Kernel Command Line
kernel_cmdline="rd.luks.uuid=<crypto_LUKS uuid> root=UUID=<btrfs uuid> rootfstype=btrfs rootflags=compress=zstd:3,subvol=@ rw"
```
```bash
lsblk -f #run this to find the uuid's
```
move aside the kernel cmdline
```bash
sudo mv /etc/kernel/cmdline /etc/kernel/cmdline.mkinitpio
```
### 2.3. Generate new uki with dracut and make sure it boots
move the current uki, you're gonna need it if the dracut's generated one fails to boot
```bash
sudo mv /boot/EFI/Linux/arch-linux.efi /boot/EFI/Linux/arch-linux-cpio.efi
```
generate new uki
```bash
sudo dracut -f -vvv
#your image name will be different, make sure you copy the right one
sudo cp /boot/EFI/Linux/linux-6.18.9-arch1-2-148874df778844e3ac264b2b65455dd6-rolling.efi /boot/EFI/Linux/arch-linux.efi
```
reboot making sure you remove limine's cmdline
if the new uki boots without problems, you're done with this section
if not, check the errors and tweak the dracut config as needed until you get a successful boot
### 2.4. Add limine support
limine support for dracut is an AUR package, I use [Chaotic Aur](https://aur.chaotic.cx/ "https://aur.chaotic.cx/"), so I use pacman to install AUR packages
if you don't use [Chaotic Aur](https://aur.chaotic.cx/ "https://aur.chaotic.cx/"), replace 'pacman' with your AUR helper ('yay', 'paru'...)
```bash
sudo pacman -S limine-dracut-support
```
edit /etc/default/limine
```bash
sudo micro /etc/default/limine
```
with this content (you can grab the cmdline from dracut.conf)
```
ENABLE_UKI=yes
KERNEL_CMDLINE[default]+=rd.luks.uuid=<crypto_LUKS uuid> root=UUID=<btrfs uuid> rootfstype=btrfs rootflags=compress=zstd:3,subvol=@ rw
```

limine-entry-tool by default will edit /boot/limine.conf while arch did install a /boot/limine/limine.conf which shadows /boot/limine.conf
to fix this I move /boot/limine/limine.conf aside, or delete it
```bash
sudo mv /boot/limine/limine.conf /boot/limine/limine.conf.aside
```
now you can generate the new limine.conf
```bash
sudo limine-update
```
check the cmdline is correct with
```bash
# replace with the newly generated efi
lsinitrd /boot/EFI/Linux/<linux efi> | head -20
```
and give a final reboot

### 2.5. Cleanup and limine.conf generation
remove mkinitcpio and it's configuration files
```bash
sudo pacman -Rsn mkinitcpio
sudo rm -rf /etc/mkinitcpio.*
```
## 3. Snapper
### 3.1. Install snapper
```bash
sudo pacman -S snapper snap-pac #inotify-tools b3sum
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
### 3.3. Add limine support
install limine-snapper-sync from the AUR
```bash
sudo pacman -S limine-snapper-sync
```
edit /etc/default/limine
```bash
sudo micro sudo micro /etc/default/limine
```
to include this line
```
ROOT_SNAPSHOTS_PATH=/@snapshots
```
to test everything, create a snapshot and sync limine with snapper
```bash
sudo snapper -c root create -d "1st snapshot"
sudo limine-snapper-sync
```
check that /boot/limine has been correctly updated and reboot
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
