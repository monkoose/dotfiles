#!/usr/bin/env bash
set -eu -o pipefail
IFS=$'\n\t'

case "$(file -b --mime-type "$1")" in
    *x-tar|*zip|*x-bzip2|*x-rar|*x-7z*)
        atool --list "$1" 2>/dev/null
        ;;
    *mp4)
        mediainfo "$1" 2>/dev/null
        ;;
    *)
        bat --plain --color=always --paging=never --theme=boa -r 1:"$3" "$1"
        ;;
esac
