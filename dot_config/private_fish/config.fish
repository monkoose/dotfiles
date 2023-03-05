if status is-interactive
    # Start X at login
    if status --is-login
        if test -z "$DISPLAY" -a $XDG_VTNR = 1
            startx
        end
    end
    # Commands to run in interactive sessions can go here
end
