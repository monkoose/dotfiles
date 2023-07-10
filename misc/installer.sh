#!/usr/bin/env bash
set -eu -o pipefail
IFS=$'\n\t'

scriptpath=$(dirname $(realpath "$0"))
cd "$scriptpath"

install_if_needed() {
    yay -Qi "$1" &>/dev/null || yay -S "$1"
}

_amdgpu() {
    # Remove tearing for amdgpu driver
    sudo mkdir -p /etc/X11/xorg.conf.d
    sudo cp xorg/20-amdgpu.conf $_

    # AMD Gpu fan speed by temperature
    install_if_needed amdfand-bin
    sudo systemctl enable --now amdfand.service
}

_keyd() {
    install_if_needed keyd
    sudo mkdir -p /etc/keyd
    sudo cp keyd/all.conf $_
}

# Install vim with custom features
_vim() {
    git clone --depth=1 https://github.com/vim/vim.git vim-repo
    cd vim-repo
    git apply ../vim/git-patch.patch
    make reconfig && sudo make install
    cd "$scriptpath" && rm -rf vim-repo
}

## Update `bat` cache so it can use custom theme
_bat() {
    install_if_needed bat
    bat cache --build
}

## xdg-user-dirs
_userdirs() {
    install_if_needed xdg-user-dirs
    xdg-user-dirs-update --set DOCUMENTS $HOME/Documents
    xdg-user-dirs-update --set DOWNLOAD $HOME/Downloads
    xdg-user-dirs-update --set PICTURES $HOME/Pictures
    xdg-user-dirs-update --set VIDEOS $HOME/Videos
    xdg-user-dirs-update --set DESKTOP $HOME/.local/share/Desktop
    xdg-user-dirs-update --set MUSIC $HOME/.local/share/Music
    xdg-user-dirs-update --set PUBLICSHARE $HOME/.local/share/Public
    xdg-user-dirs-update --set TEMPLATES $HOME/.local/share/Templates
}

# main script
config_funcs=(
    _amdgpu
    _keyd
    _bat
    _userdirs
)

for func in "${config_funcs[@]}"; do
    echo "Running $func"
    $func
done

echo "Done."
