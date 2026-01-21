#!/usr/bin/env bash

PACKAGES=(
    blueman brightnessctl btop cliphist firefox flatpak fzf 
    gnome-themes-extra grim hypridle hyprlock inter-font kitty 
    less libnotify libqalculate micro noto-fonts noto-fonts-cjk
    noto-fonts-emoji noto-fonts-extra slurp starship stow swappy
    swww tesseract-data-eng ttc-iosevka-ss08 ttf-nerd-fonts-symbols
    ttf-nerd-fonts-symbols-common ttf-nerd-fonts-symbols-mono
    wl-clipboard xwayland-satellite zip zoxide zsh
)

# Use --needed to skip already installed packages
# Use --noconfirm if you want it to run unattended
sudo pacman -S --needed "${PACKAGES[@]}"

# Setup Flatpak
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Set Theme Preferences
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface gtk-theme Adwaita-dark

# Clean up and Stow
rm -rf ~/.config/micro ~/.config/niri
stow hypr kitty mako micro niri starship waybar zsh

# Ensure Pictures directory exists before copying
mkdir -p ~/Pictures/
cp -R Wallpapers ~/Pictures/
