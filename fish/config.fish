if status is-interactive
    # Commands to run in interactive sessions can go here
end

# Load modular configs
for file in ~/.config/fish/modules/*.fish
    source $file
end

# direnv hook
eval (direnv hook fish)

