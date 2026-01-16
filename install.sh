#!/bin/bash

sudo pacman -S \
    blueman \
    brightnessctl \
    btop \
    firefox \
    flatpak \
    fzf \
    #gnome-themes-extra \
    #google-noto-sans-cjk-vf-fonts \
    grim \
    hypridle \
    hyprlock \
    kitty \
    mako \
    micro \
    nautilus \
    #niri \
    #nm-connection-editor \
    #pavucontrol \
    #pipewire-utils \
    #plymouth-system-theme \
    slurp \
    starship \
    stow \
    swappy \
    swww \
    wl-clipboard \
    zoxide \
    zsh
default-theme -R "bgrt"

sudo flatpak remote-add --if-not-exists flathub \
    https://dl.flathub.org/repo/flathub.flatpakrepo

#flatpak install flathub io.github.kolunmi.Bazaar

#gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
#gsettings set org.gnome.desktop.interface gtk-theme Adwaita-dark
#xdg-user-dirs-update

stow btop fonts kitty micro niri swappy wallpapers waybar zsh
