#!/usr/bin/env bash

# KDE plasma
sudo pacman -S --needed $(pacman -Sg plasma | awk '{print $2}' | grep -v 'sddm-kcm')
sudo systemctl enable plasmalogin.service

# kitty & co
sudo pacman -S --needed kitty micro starship zsh fzf zoxide stow

# my favourite fonts
sudo pacman -S --needed ttc-iosevka-aile ttc-iosevka-ss12

# stowaway!
rm -rf ~/.config/micro
stow kitty micro starship zsh
