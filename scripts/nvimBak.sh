#!/bin/bash

# Function to create a backup of Neovim configuration folders
backup_neovim_config() {
    local backup_dir="$HOME/.backup/neovim_backup_$(date +'%Y-%m-%d_%H-%M-%S')"
    local config_dir="$HOME/.config"
    local local_dir="$HOME/.local"
    local cache_dir="$HOME/.cache"
    local state_dir="$HOME/.local/state"

    # Check if Neovim config folders exist
    if [ -d "$config_dir/nvim" ] || [ -d "$local_dir/share/nvim" ] || [ -d "$cache_dir/nvim" ] || [ -d "$state_dir/nvim" ]; then
        echo "Creating backup of Neovim configuration..."

        # Create backup directory
        mkdir -p "$backup_dir"

        # Copy .config/nvim
        if [ -d "$config_dir/nvim" ]; then
            cp -r "$config_dir/nvim" "$backup_dir"
        fi

        # Copy .local/share/nvim
        if [ -d "$local_dir/share/nvim" ]; then
            cp -r "$local_dir/share/nvim" "$backup_dir/share"
        fi

        # Copy .cache/nvim
        if [ -d "$cache_dir/nvim" ]; then
            cp -r "$cache_dir/nvim" "$backup_dir/cache"
        fi

        # Copy .local/state/nvim
        if [ -d "$state_dir/nvim" ]; then
            cp -r "$state_dir/nvim" "$backup_dir/state"
        fi

        echo "Backup completed. Location: $backup_dir"
    else
        echo "Neovim configuration not found."
    fi
}

# Main script
backup_neovim_config
