#!/usr/bin/env bash
set -e

DOTFILES="$HOME/dotfiles"
BACKUP=false
TIMESTAMP=$(date +%Y%m%d_%H%M%S)   
BACKUP_DIR="$HOME/dotfiles_backup_$TIMESTAMP"

while getopts "b" opt; do
    case $opt in
        b)
            BACKUP=true
            mkdir -p "$BACKUP_DIR"
            ;;
        *)
            echo "Usage: $0 [-b]"
            exit 1
            ;;
    esac
done

echo "=== Dotfiles installer ==="

if $BACKUP; then
    echo "Existing configs will be backed up to: ~/$(basename $BACKUP_DIR)"
fi

# Function to safely link files or directories
link_dotfile() {
    local src="$1"
    local dest="$2"

    # Remove or backup existing
    if [ -e "$dest" ] || [ -L "$dest" ]; then
        if $BACKUP; then
            echo "Backing up existing: $dest"
            mv "$dest" "$BACKUP_DIR/"
        else
            echo "Removing existing: $dest"
            rm -rf "$dest"
        fi
    fi

    # Create parent directory if it doesn't exist
    mkdir -p "$(dirname "$dest")"

    echo "Linking $src → $dest"
    ln -s "$src" "$dest"
}

link_dotfile "$DOTFILES/fish" "$HOME/.config/fish"
link_dotfile "$DOTFILES/tmux" "$HOME/.config/tmux"
link_dotfile "$DOTFILES/nvim" "$HOME/.config/nvim"
link_dotfile "$DOTFILES/hypr" "$HOME/.config/hypr"
link_dotfile "$DOTFILES/yazi" "$HOME/.config/yazi"
link_dotfile "$DOTFILES/kitty" "$HOME/.config/kitty"
link_dotfile "$DOTFILES/btop" "$HOME/.config/btop"
link_dotfile "$DOTFILES/starship.toml" "$HOME/.config/starship.toml"

link_dotfile "$DOTFILES/swaync" "$HOME/.config/swaync"
link_dotfile "$DOTFILES/rofi" "$HOME/.config/rofi"
link_dotfile "$DOTFILES/waybar" "$HOME/.config/waybar"
link_dotfile "$DOTFILES/nwg-look" "$HOME/.config/nwg-look"
link_dotfile "$DOTFILES/gtk-3.0" "$HOME/.config/gtk-3.0"
link_dotfile "$DOTFILES/gtk-4.0" "$HOME/.config/gtk-4.0"

link_dotfile "$DOTFILES/qBittorrent" "$HOME/.config/qBittorrent"

link_dotfile "$DOTFILES/qtile" "$HOME/.config/qtile"
link_dotfile "$DOTFILES/vlc" "$HOME/.config/vlc"

link_dotfile "$DOTFILES/scripts" "$HOME/Downloads/scripts"

# --- Done ---
echo "=== Dotfiles linked successfully! ==="
if $BACKUP; then
    echo "Backups stored in: ~/$(basename $BACKUP_DIR)"
fi
