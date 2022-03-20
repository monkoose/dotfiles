function fish_control_k
    if commandline --paging-mode
        commandline --function complete-and-search
    else
        commandline --function kill-line
    end
end
