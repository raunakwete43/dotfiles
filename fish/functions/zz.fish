set -g ZZ_EXCLUDES ".cache" ".bun" "node_modules" ".local/share/nvim" ".cursor" ".vscode" ".git" "go/pkg" ".cargo" ".pub*"
".yarn" ".pnpm-store" ".npm" "Code" ".venv" "__pycache__"

function zz
    set use_excludes 1
    set query

    # Parse args
    if test (count $argv) -eq 0
        echo "Usage: zz [-a] <pattern>"
        return 1
    end

    if test $argv[1] = "-a"
        set use_excludes 0
        set query $argv[2]
    else
        set query $argv[1]
    end

    # Build exclude args only if enabled
    set exclude_args
    if test $use_excludes -eq 1
        for e in $ZZ_EXCLUDES
            set exclude_args $exclude_args --exclude $e
        end
    end

    # Run fd search
    set matches (fd -H -I -t d $query $HOME $exclude_args \
        | awk '{ print length, $0 }' | sort -n | cut -d" " -f2-)

    if test (count $matches) -eq 0
        echo "No matching directory found for: $query"
        return 1
    else if test (count $matches) -eq 1
        cd $matches[1]
    else
        set dir (printf '%s\n' $matches | fzf)
        if test -n "$dir"
            cd $dir
        else
            echo "No directory selected"
        end
    end
end
