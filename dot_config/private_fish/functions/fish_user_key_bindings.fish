function fish_user_key_bindings
    fzf_key_bindings
    bind --user \el echo\ -n\ \(clear\ \|\ string\ replace\ \\e\\\[3J\ \"\"\)\;\ commandline\ -f\ repaint
    bind --user \eF forward-bigword
    bind --user \eB backward-bigword
    bind --preset \ef nextd-or-forward-word
    bind --preset \eb prevd-or-backward-word
    bind --user \er 'commandline -i " | "'
    bind --user \cj fish_control_j
    bind --user \ck fish_control_k
    bind --user \cl fish_control_l
end
