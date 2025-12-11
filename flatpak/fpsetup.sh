#!/bin/bash

flatpak remote-delete -y fedora
flatpak remote-add -y --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

flatpak install -y flathub io.github.kolunmi.Bazaar
flatpak install -y flathub app.zen_browser.zen

