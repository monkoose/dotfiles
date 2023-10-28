#!/usr/bin/env bash
set -eu -o pipefail
IFS=$'\n\t'

# functions {{{

install_if_needed() {
    yay -Qi "$1" &>/dev/null || yay -S "$1"
}

_amdgpu() {
    # Remove tearing for amdgpu driver
    sudo mkdir -p /etc/X11/xorg.conf.d
    sudo cp xorg/20-amdgpu.conf "$_"

    # AMD Gpu fan speed by temperature
    install_if_needed amdfand-bin
    sudo systemctl enable --now amdfand.service
}

_keyd() {
    install_if_needed keyd
    sudo mkdir -p /etc/keyd
    sudo cp keyd/all.conf "$_"
}

# Install vim with custom features
_vim() {
    rm -rf vim-repo
    git clone --depth=1 https://github.com/vim/vim.git vim-repo
    cd vim-repo
    git apply ../vim/git-patch.patch
    make reconfig && sudo make install
    cd "$scriptpath" && rm -rf vim-repo
    sudo rm -rf /usr/local/share/vim/vimfiles
    sudo ln -s /usr/share/vim/vimfiles /usr/local/share/vim/vimfiles
}

_st() {
    cd st-terminal && makepkg -Csif
    rm -rf pkg src ./*tar.gz ./*tar.zst
    cd "$scriptpath"
}

## Update `bat` cache so it can use custom theme
_bat() {
    install_if_needed bat
    bat cache --build
}

## xdg-user-dirs
_userdirs() {
    install_if_needed xdg-user-dirs
    mkdir -p "$HOME/Documents"
    mkdir -p "$HOME/Downloads"
    mkdir -p "$HOME/Pictures"
    mkdir -p "$HOME/Videos"
    mkdir -p "$HOME/.local/share/Desktop"
    mkdir -p "$HOME/.local/share/Music"
    mkdir -p "$HOME/.local/share/Public"
    mkdir -p "$HOME/.local/share/Templates"
    xdg-user-dirs-update --set DOCUMENTS "$HOME/Documents"
    xdg-user-dirs-update --set DOWNLOAD "$HOME/Downloads"
    xdg-user-dirs-update --set PICTURES "$HOME/Pictures"
    xdg-user-dirs-update --set VIDEOS "$HOME/Videos"
    xdg-user-dirs-update --set DESKTOP "$HOME/.local/share/Desktop"
    xdg-user-dirs-update --set MUSIC "$HOME/.local/share/Music"
    xdg-user-dirs-update --set PUBLICSHARE "$HOME/.local/share/Public"
    xdg-user-dirs-update --set TEMPLATES "$HOME/.local/share/Templates"
}

_consolefont() {
    install_if_needed tamsyn-font
    sudo sh -c "echo 'FONT=Tamsyn10x20b' > /etc/vconsole.conf"
}

_get() {
    pacman -Qeq > packages.txt
}

_pack() {
    while IFS= read -r line; do
        install_if_needed "$line"
    done < packages.txt
}
# }}}

# main script
scriptpath=$(dirname "$(realpath "$0")")
cd "$scriptpath"

funcs=(
    _pack
    _amdgpu
    _keyd
    _bat
    _userdirs
    _consolefont
    _st
    # _vim
)

if [[ $# -eq 0 ]]
then
    for func in "${funcs[@]}"; do
        echo "Running $func"
        $func
    done
else
    (_"$1")
fi

echo "Done."

# vim: fdm=marker
