It sounds like you're setting up a robust rollback system for Arch Linux! I've converted your text into a clean, organized Markdown document. I've standardized the formatting, highlighted key file paths, and cleaned up the code blocks for better readability.

---

# Setting Up Snapper and Limine Integration

This guide outlines the steps to configure Btrfs snapshots with Limine bootloader integration on Arch Linux.

## 1. Install Required Packages

Use your preferred AUR helper (e.g., `yay` or `paru`) to install the core synchronization and bootloader integration tools.

```bash
# Core tools and Snapper
sudo pacman -S snapper snap-pac

# AUR tools for Limine integration (Pick the hook for your initramfs tool)
# For mkinitcpio users:
yay -S limine-snapper-sync limine-mkinitcpio-hook

# For Dracut users:
yay -S limine-snapper-sync limine-dracut-support

```

## 2. Initial Snapper Configuration

Configure Snapper for your root partition and set the necessary subvolume permissions.

```bash
# Remove default mount point if it exists
sudo umount /.snapshots 2>/dev/null
sudo rm -rf /.snapshots

# Create the root config
sudo snapper -c root create-config /

# Re-mount your snapshots subvolume if using a custom layout, then set permissions
sudo chmod 750 /.snapshots
sudo chown :wheel /.snapshots

```

## 3. Add OverlayFS to Initramfs

To ensure snapshots are bootable even if the root is read-only, you must add an OverlayFS hook.

**For mkinitcpio:**

1. Open `/etc/mkinitcpio.conf` with a text editor.
2. Find the `HOOKS=(...)` line.
3. Add `btrfs-overlayfs` (or `sd-btrfs-overlayfs` if using systemd hooks) immediately after `filesystems`.
4. Save and apply:

```bash
sudo limine-update

```

## 4. Configure Limine Snapshot Entries

You must tell Limine where to place the auto-generated snapshot menu.

1. Open your Limine configuration (usually at `/boot/limine.conf` or `/efi/limine.conf`).
2. Add the `//Snapshots` keyword at the end of your main Arch Linux entry:

```text
//Arch Linux
    protocol: linux
    path: boot():/vmlinuz-linux
    cmdline: root=UUID=your-uuid-here rw rootflags=subvol=@
    module_path: boot():/initramfs-linux.img

//Snapshots

```

## 5. Enable Synchronization

Verify your ESP (EFI System Partition) path and enable the automation services.

```bash
# Check if your ESP is detected
bootctl --print-esp-path

# If NOT detected, manually set it (e.g., if ESP is at /efi)
echo "ESP_PATH=/efi" | sudo tee -a /etc/default/limine

# Create an initial snapshot and sync
sudo snapper -c root create -d "Initial Setup"
sudo limine-snapper-sync

# Enable background automation
sudo systemctl enable --now limine-snapper-sync.service
sudo systemctl enable --now snapper-cleanup.timer

```

---

