# Personal aliases for fish shell
alias pixel_refresh='~/Projects/Python/screen_refresh/.venv/bin/python3 ~/Projects/Python/screen_refresh/main.py'
alias zed='zeditor'

alias nvim-kickstart='NVIM_APPNAME="nvim-kickstart" nvim'
alias nvim-deps='NVIM_APPNAME="nvim-deps" nvim'
alias nvim-lazy='NVIM_APPNAME="nvim-lazy" nvim'
alias nv='nvim'
alias nk='nvim-kickstart'
alias nl='nvim-lazy'
alias nd='nvim-deps'
alias rm='trash'
alias zbinds="bash ~/Downloads/scripts/zbinds"
alias emc="emacsclient -c -a 'emacs'"


alias mpv="mpv --hwdec=auto --vo=gpu --profile=fast"

export EDITOR="nvim"
export VISUAL="nvim"

#Aliases
alias traffic='~/Documents/new1.sh wlp1s0'
alias automute='~/Downloads/scripts/automute.sh'
alias enbar='~/Downloads/scripts/dwmblocks.sh'
alias extract='~/Downloads/scripts/extract.sh'
alias 8086='~/.cargo/bin/emulator_8086'


# Python
alias py3='python3'
alias activate_fish='source ~/.config/fish/config.fish'



#list
alias ls='lsd'
alias la='lsd -a'
alias ll='lsd -al'
alias l='ls'
alias l.="lsd -A | egrep '^\.'"
alias listdir="lsd -d */ > list"

#speedtest
alias speed='~/Downloads/scripts/speedtest'



# Clipboard aliases (macOS-like pbcopy/pbpaste)
if test "$XDG_SESSION_TYPE" = "wayland"
    alias pbcopy='wl-copy'
    alias pbpaste='wl-paste'
else if test "$XDG_SESSION_TYPE" = "x11"
    alias pbcopy='xclip -selection clipboard'
    alias pbpaste='xclip -selection clipboard -o'
else
    # fallback (in case variable missing or unknown session)
    if type -q wl-copy
        alias pbcopy='wl-copy'
        alias pbpaste='wl-paste'
    else if type -q xclip
        alias pbcopy='xclip -selection clipboard'
        alias pbpaste='xclip -selection clipboard -o'
    end
end


#fix obvious typo's
alias cd..='cd ..'
# alias pdw='pwd'

## Colorize the grep command output for ease of use (good for log files)##
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

#readable output
alias df='df -h'

#ncdu
alias ncdu='ncdu --color dark-bg'

#Cleanup orphaned packages
alias cleanup='sudo pacman -Rns $(pacman -Qtdq)'

#search content with ripgrep
alias rg="rg --sort path"

#check vulnerabilities microcode
alias microcode='grep . /sys/devices/system/cpu/vulnerabilities/*'

#get the error messages from journalctl
alias jctl="journalctl -p 3 -xb"
