#!/bin/bash

sudo flatpak remote-delete fedora
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

sudo dnf copr enable atim/starship
sudo dnf install fastfetch fzf neovim starship stow zoxide zsh
#sudo dnf install firefox ptyxis

sudo systemctl stop packagekit.service
sudo systemctl mask packagekit.service
sudo systemctl stop packagekit-offline-update.service
sudo systemctl mask packgekit-offline-update.service
sudo dnf remove PackageKit plasma-discover
flatpak install flathub io.github.kolunmi.Bazaar

sudo dnf remove kmahjongg kmines kpat
