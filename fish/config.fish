if status is-interactive
    # Commands to run in interactive sessions can go here
end

# Load modular configs
for file in ~/.config/fish/modules/*.fish
    source $file
end

# direnv hook
# eval (direnv hook fish)

eval "$(fnm env)"

# pnpm
set -gx PNPM_HOME "/home/manu/.local/share/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end
