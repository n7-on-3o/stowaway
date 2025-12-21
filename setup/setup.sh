#!/bin/bash

sudo flatpak remote-delete fedora
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

sudo dnf copr enable atim/starship
sudo dnf install fastfetch fzf neovim starship stow zoxide zsh
#sudo dnf install firefox ptyxis

systemctl stop packagekit.service
systemctl mask packagekit.service
systemctl stop packagekit-offline-update.service
systemctl mask packgekit-offline-update.service
sudo dnf remove PackageKit plasma-discover
flatpak install flathub io.github.kolunmi.Bazaar
