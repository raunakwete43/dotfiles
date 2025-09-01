set PATH /usr/sbin $PATH
set PATH /usr/local/go/bin $PATH
set PATH $HOME/go/bin $PATH
set PATH $HOME/.config/emacs/bin/ $PATH
set PATH $HOME/Android/Sdk/emulator/ $PATH
set PATH $HOME/Android/Sdk/platform-tools/ $PATH
set PATH $HOME/.pub-cache/bin/ $PATH
set PATH $HOME/Android/Sdk/cmdline-tools/latest/bin $PATH
set PATH /opt/rocm/bin/ $PATH
set PATH $PATH $HOME/Downloads/flutter/bin/
set PATH $PATH $HOME/.npm-global/bin


set PATH $PATH $HOME/.local/bin

# Added by LM Studio CLI (lms)
set -gx PATH $PATH /home/manu/.lmstudio/bin

# opencode
fish_add_path /home/manu/.opencode/bin


# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH
