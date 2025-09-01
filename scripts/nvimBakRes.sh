#!/bin/bash

# Function to restore Neovim configuration from backup directory
restore_neovim_config() {
    local backup_dir="$1"

    # Check if backup directory exists
    if [ -d "$backup_dir" ]; then
        echo "Restoring Neovim configuration from backup..."

        # Restore .config/nvim
        if [ -d "$backup_dir/nvim" ]; then
            cp -r "$backup_dir/nvim" "$HOME/.config"
        fi

        # Restore .local/share/nvim
        if [ -d "$backup_dir/share/nvim" ]; then
            cp -r "$backup_dir/share/nvim" "$HOME/.local/share"
        fi

        # Restore .cache/nvim
        if [ -d "$backup_dir/nvim" ]; then
            cp -r "$backup_dir/nvim" "$HOME/.cache"
        fi

        # Restore .local/state/nvim
        if [ -d "$backup_dir/state/nvim" ]; then
            cp -r "$backup_dir/state/nvim" "$HOME/.local/state"
        fi

        echo "Neovim configuration restored successfully."
    else
        echo "Backup directory not found."
    fi
}

# Main script
if [ $# -eq 1 ]; then
    restore_neovim_config "$1"
else
    echo "Usage: $0 <backup_directory>"
fi

