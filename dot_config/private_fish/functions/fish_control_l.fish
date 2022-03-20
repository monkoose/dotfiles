function fish_control_l
    if commandline --paging-mode
        commandline --function execute
    else
        echo -n (clear | string replace \e\\\[3J "")
        commandline -f repaint
    end
end
