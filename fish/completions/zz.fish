# ~/.config/fish/completions/zz.fish

function __zz_directory_completions
    # Use same excludes as main function
    set -l exclude_args
    for e in $ZZ_EXCLUDES
        set exclude_args $exclude_args --exclude $e
    end

    # Get weighted directories from history
    set -l weighted_dirs
    if set -q ZZ_HISTFILE && test -f "$ZZ_HISTFILE"
        set weighted_dirs (
            cut -d'|' -f2- "$ZZ_HISTFILE" \
            | sort | uniq -c | sort -nr \
            | awk '{printf "%d|%s\n", $1, $2}' \
            | head -n 50
        )
    end

    # Generate current directory matches
    set -l current_matches (
        fd -H -I -t d '' $HOME $exclude_args \
        | awk '{print "0|" $0}' \
        | head -n 200
    )

    # Combine and sort (history first, then by path length)
    printf "%s\n" $weighted_dirs $current_matches \
        | awk -F'|' '{print length($2), $1, $2}' \
        | sort -t' ' -k2nr -k1n \
        | cut -d' ' -f3- \
        | sed "s|^$HOME|~|" \
        | head -n 100
end

complete -c zz -f \
    -a "(__zz_directory_completions)" \
    -n "not __fish_contains_opt -s a all" \
    -d "Directory"

complete -c zz -s a -l all -f -d "Search all directories"
complete -c zz -s p -l preview -f -d "Show directory preview"
complete -c zz -s h -l help -f -d "Show help"
