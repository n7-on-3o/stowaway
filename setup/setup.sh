#!/bin/bash

sudo flatpak remote-delete fedora
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

sudo dnf copr enable atim/starship
sudo dnf install fastfetch fzf neovim starship stow zoxide zsh
