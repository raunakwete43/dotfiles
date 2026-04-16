if status is-interactive
    # Commands to run in interactive sessions can go here
end

# Load modular configs
for file in ~/.config/fish/modules/*.fish
    source $file
end

# direnv hook
eval (direnv hook fish)

eval "$(fnm env)"


# Added by LM Studio CLI (lms)
set -gx PATH $PATH /home/manu/.lmstudio/bin
# End of LM Studio CLI section


# lean-ctx shell hook — transparent CLI compression (90+ patterns)
set -g _lean_ctx_cmds git npm pnpm yarn cargo docker docker-compose kubectl gh pip pip3 ruff go golangci-lint eslint prettier tsc ls find grep curl wget

function _lc
	if set -q LEAN_CTX_DISABLED; or not isatty stdout
		command $argv
		return
	end
	'/home/manu/.cargo/bin/lean-ctx' -c $argv
	set -l _lc_rc $status
	if test $_lc_rc -eq 127 -o $_lc_rc -eq 126
		command $argv
	else
		return $_lc_rc
	end
end

function lean-ctx-on
	for _lc_cmd in $_lean_ctx_cmds
		alias $_lc_cmd '_lc '$_lc_cmd
	end
	alias k '_lc kubectl'
	set -gx LEAN_CTX_ENABLED 1
	echo 'lean-ctx: ON'
end

function lean-ctx-off
	for _lc_cmd in $_lean_ctx_cmds
		functions --erase $_lc_cmd 2>/dev/null; true
	end
	functions --erase k 2>/dev/null; true
	set -e LEAN_CTX_ENABLED
	echo 'lean-ctx: OFF'
end

function lean-ctx-raw
	set -lx LEAN_CTX_RAW 1
	command $argv
end

function lean-ctx-status
	if set -q LEAN_CTX_DISABLED
		echo 'lean-ctx: DISABLED (LEAN_CTX_DISABLED is set)'
	else if set -q LEAN_CTX_ENABLED
		echo 'lean-ctx: ON'
	else
		echo 'lean-ctx: OFF'
	end
end

if not set -q LEAN_CTX_ACTIVE; and not set -q LEAN_CTX_DISABLED; and test (set -q LEAN_CTX_ENABLED; and echo $LEAN_CTX_ENABLED; or echo 1) != '0'
	if command -q lean-ctx
		lean-ctx-on
	end
end
# lean-ctx shell hook — end
