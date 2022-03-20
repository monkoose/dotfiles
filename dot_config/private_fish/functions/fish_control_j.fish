function fish_control_j
    if commandline --paging-mode
        commandline --function complete
    else
        commandline --function complete-and-search
    end
end
