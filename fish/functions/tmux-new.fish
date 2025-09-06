function tmux-new
    if test (count $argv) -lt 1
        echo "Usage: tmux-new <session-name> [directory]"
        return 1
    end

    set session $argv[1]
    if test (count $argv) -ge 2
        set dir $argv[2]
    else
        set dir (pwd)
    end

    tmux new-session -ds "$session" -c "$dir"
end

