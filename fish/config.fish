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





# lean-ctx shell hook — smart shell mode (track-by-default)
set -g _lean_ctx_cmds git gh cargo npm pnpm yarn bun bunx deno vite pip pip3 pytest mypy ruff go golangci-lint docker docker-compose kubectl helm aws terraform tofu eslint prettier tsc biome curl wget php composer dotnet bundle rake mix swift zig cmake make rg

function _lc
	if set -q LEAN_CTX_DISABLED; or not isatty stdout
		command $argv
		return
	end
	'/home/manu/.local/bin/lean-ctx' -t $argv
	set -l _lc_rc $status
	if test $_lc_rc -eq 127 -o $_lc_rc -eq 126
		command $argv
	else
		return $_lc_rc
	end
end

function _lc_compress
	if set -q LEAN_CTX_DISABLED; or not isatty stdout
		command $argv
		return
	end
	'/home/manu/.local/bin/lean-ctx' -c $argv
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
	isatty stdout; and echo 'lean-ctx: ON (track mode — full output, stats recorded)'
end

function lean-ctx-off
	for _lc_cmd in $_lean_ctx_cmds
		functions --erase $_lc_cmd 2>/dev/null; true
	end
	functions --erase k 2>/dev/null; true
	set -e LEAN_CTX_ENABLED
	isatty stdout; and echo 'lean-ctx: OFF'
end

function lean-ctx-mode
	switch $argv[1]
		case compress
			for _lc_cmd in $_lean_ctx_cmds
				alias $_lc_cmd '_lc_compress '$_lc_cmd
				end
			alias k '_lc_compress kubectl'
			set -gx LEAN_CTX_ENABLED 1
			isatty stdout; and echo 'lean-ctx: COMPRESS mode (all output compressed)'
		case track
			lean-ctx-on
		case off
			lean-ctx-off
		case '*'
			echo 'Usage: lean-ctx-mode <track|compress|off>'
			echo '  track    — Full output, stats recorded (default)'
			echo '  compress — Compressed output for all commands'
			echo '  off      — No aliases, raw shell'
	end
end

function lean-ctx-raw
	set -lx LEAN_CTX_RAW 1
	command $argv
end

function lean-ctx-status
	if set -q LEAN_CTX_DISABLED
		isatty stdout; and echo 'lean-ctx: DISABLED (LEAN_CTX_DISABLED is set)'
	else if set -q LEAN_CTX_ENABLED
		isatty stdout; and echo 'lean-ctx: ON'
	else
		isatty stdout; and echo 'lean-ctx: OFF'
	end
end

if not set -q LEAN_CTX_ACTIVE; and not set -q LEAN_CTX_DISABLED; and test (set -q LEAN_CTX_ENABLED; and echo $LEAN_CTX_ENABLED; or echo 1) != '0'
	if command -q lean-ctx
		lean-ctx-on
	end
end
# lean-ctx shell hook — end
