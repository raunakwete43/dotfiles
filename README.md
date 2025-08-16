# My Dotfiles

![License](https://img.shields.io/github/license/raunakwete43/dotfiles)
![Last Update](https://img.shields.io/github/last-commit/raunakwete43/dotfiles)

## ✨ Overview
A curated collection of configuration files for Linux power users. This repo includes custom setups for Fish shell, Neovim, Hyprland, Qtile, Rofi, Waybar, and more. Designed for a beautiful, productive, and highly customizable Linux experience.

## 📦 Features
- Modular Fish shell configuration with aliases, environment variables, and completions
- Neovim setup with plugin management and custom themes
- Hyprland and Qtile window manager configs for tiling and dynamic layouts
- Rofi launchers, themes, and applets for fast navigation
- Waybar, Kitty, Yazi, SwayNC, NWG-Look, and more for a cohesive desktop look
- Starship prompt configuration for a stylish terminal
- Scripts and automation for productivity
- Easy backup and restore via install script

## 🚀 Installation

### Prerequisites
- Linux (tested on Arch, Ubuntu, etc.)
- Git
- Recommended: fish, neovim, hyprland, qtile, rofi, waybar, kitty, yazi, swaync, nwg-look, starship, btop, vlc, qBittorrent

### Quick Install

Clone the repository:
```bash
git clone https://github.com/raunakwete43/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

Run the installer (optionally backup existing configs):
```bash
./install.sh           # Symlinks configs to ~/.config
./install.sh -b        # Backs up existing configs before linking
```

Or symlink manually:
```bash
ln -s ~/dotfiles/fish ~/.config/fish
ln -s ~/dotfiles/nvim ~/.config/nvim
# ...repeat for other configs as needed
```

### Updating
```bash
cd ~/dotfiles
git pull
./install.sh
```

## 🛠️ Usage
- **Fish shell:** Launch with `fish`. Modular configs auto-load from `modules/`.
- **Neovim:** Start with `nvim`. Plugins managed via lazy.nvim and NvChad.
- **Hyprland:** Start with `Hyprland` (Wayland compositor). Configs in `hypr/`.
- **Qtile:** Start with `qtile`. Configs in `qtile/`.
- **Rofi:** Launch with `rofi -show drun -theme ~/.config/rofi/colors/catppuccin.rasi`.
- **Waybar:** Start with `waybar`. Configs in `waybar/`.
- **Kitty:** Start with `kitty`. Configs in `kitty/`.
- **Yazi:** Start with `yazi`. Configs in `yazi/`.
- **Starship:** Prompt config in `starship.toml`.
- **Other apps:** See respective folders for configs.

## 📁 Directory Structure
```
fish/           # Fish shell configs
nvim/           # Neovim configs
hypr/           # Hyprland configs
qtile/          # Qtile configs
rofi/           # Rofi themes, launchers, applets
waybar/         # Waybar configs
kitty/          # Kitty terminal configs
yazi/           # Yazi file manager configs
swaync/         # SwayNC notification center
nwg-look/       # NWG-Look configs
btop/           # Btop system monitor
qBittorrent/    # qBittorrent configs
vlc/            # VLC configs
starship.toml   # Starship prompt config
install.sh      # Installer script
LICENSE         # MIT License
```

## 🐞 Troubleshooting
- If an app doesn’t pick up the config, check symlink paths and permissions.
- For backup issues, ensure you have write access to `$HOME`.
- Some configs require specific versions of apps (e.g., Neovim 0.9+, Fish 3.5+).
- For Wayland/Hyprland, ensure your session is running Wayland.

## 🤝 Contributing
Pull requests and suggestions are welcome! Please open an issue or PR for improvements.

## 📜 License
MIT License (see LICENSE)
