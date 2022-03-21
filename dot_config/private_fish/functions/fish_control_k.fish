function fish_control_k
    if commandline --paging-mode
        commandline -f complete-and-search
    else
        commandline -f kill-line
    end
end
