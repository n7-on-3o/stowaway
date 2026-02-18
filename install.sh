#!/usr/bin/env bash

# KDE plasma
pacman -Sgq plasma | grep -vE 'discover|sddm-kcm' | sudo pacman -S -
sudo systemctl enable plasmalogin.service

# kitty & co
sudo pacman -S --needed kitty micro starship zsh fzf zoxide stow

# my favourite fonts
sudo pacman -S --needed ttc-iosevka-aile ttc-iosevka-ss12

# stowaway!
rm -rf ~/.config/micro
stow kitty micro starship zsh
