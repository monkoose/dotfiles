function fish_control_l
    if commandline --paging-mode
        commandline -f execute
    else
        commandline -f accept-autosuggestion
    end
end
