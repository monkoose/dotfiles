#!/usr/bin/env bash

install_if_not() {
    yay -Qi "$1" &>/dev/null || yay -S "$1"
}

scriptpath=$(dirname $(realpath "$0"))
cd "$scriptpath"

# Remove tearing for amdgpu driver
mkdir -p /etc/X11/xorg.conf.d
cp misc/xorg/20-amdgpu.conf $_

# AMD Gpu fan speed by temperature
install_if_needed amdfand-bin
systemctl enable --now amdfand.service

# keyd
install_if_needed keyd
mkdir -p /etc/keyd
cp keyd/all.conf $_

# Install vim with custom features
git clone https://github.com/vim/vim.git vim-repo
cd vim-repo
git apply misc/vim/git-patch.patch
make reconfig && make install
cd "$scriptpath"

## Update `bat` cache so it can use custom theme
install_if_needed bat
bat cache --build

## xdg-user-dirs
install_if_needed xdg-user-dirs
xdg-user-dirs-update --set TEMPLATES $HOME/.local/share/Templates
xdg-user-dirs-update --set PUBLICSHARE $HOME/.local/share/Public
xdg-user-dirs-update --set DESKTOP $HOME/.local/share/Desktop
xdg-user-dirs-update --set DOWNLOAD $HOME/Downloads
xdg-user-dirs-update --set DOCUMENTS $HOME/Documents
xdg-user-dirs-update --set VIDEOS $HOME/Videos
xdg-user-dirs-update --set PICTURES $HOME/Pictures
