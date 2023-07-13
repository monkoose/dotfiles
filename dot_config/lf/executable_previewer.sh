#!/usr/bin/env bash
set -eu -o pipefail
IFS=$'\n\t'

if [[ $(xdg-mime query filetype "$1") == *zip ]]
then
    atool --list "$1" 2>/dev/null
else
    bat --plain --color=always --paging=never --theme=boa -r 1:"$3" "$1"
fi
