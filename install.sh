#!/usr/bin/env bash

if [[ "$1" == "--desktop" ]] || [[ "$1" == "-d" ]]; then
    DEVICE="desktop"
fi

if [[ "$1" == "--laptop" ]] || [[ "$1" == "-l" ]]; then
    DEVICE="laptop"
fi

if [ -z $DEVICE ]; then
    echo "Provide an argument: --desktop (-d) or --laptop (-l)"
    exit 0
fi

PACKAGES=(
    blueman brightnessctl btop cliphist ddcutil firefox flatpak
    fzf gnome-themes-extra grim hypridle hyprlock kitty less
    libnotify libqalculate micro noto-fonts noto-fonts-cjk
    noto-fonts-emoji noto-fonts-extra slurp starship stow swappy
    swww tesseract-data-eng ttc-iosevka-ss08 ttf-ubuntu-mono-nerd
    ufw wl-clipboard xwayland-satellite zip zoxide zsh
)

# Use --needed to skip already installed packages
# Use --noconfirm if you want it to run unattended
sudo pacman -S --needed "${PACKAGES[@]}"

# Setup Firewall
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw enable

# Setup Flatpak
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Set Theme Preferences
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface gtk-theme Adwaita-dark

# Clean up and Stow
rm -rf ~/.config/micro ~/.config/niri
stow fuzzel hypr kitty mako micro niri starship swappy waybar zsh
cp ./waybar/.config/waybar/config.jsonc.$DEVICE ./waybar/.config/waybar/config.jsonc

# Ensure Pictures directory exists before copying
mkdir -p ~/Pictures/
cp -R Wallpapers ~/Pictures/
