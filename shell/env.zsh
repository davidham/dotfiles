#!/usr/bin/env zsh
# Environment variables and PATH. Sourced first by home/zshrc.zsh.
# shellcheck shell=bash

# --- XDG Base Directory ---
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# Ensure XDG state/cache dirs that hold relocated histories exist.
for d in "$XDG_STATE_HOME"/{zsh,less,psql,python,node} "$XDG_CACHE_HOME"/zsh; do
  [[ -d $d ]] || mkdir -p "$d"
done
unset d

# --- PATH ---
# Order: most-specific first. asdf shims (prepended below) end up at the
# front. /opt/homebrew/bin is added by `brew shellenv` in ~/.zprofile,
# which zshrc.zsh sources AFTER this file, so it does not appear here.
# In zsh, the `path` array and `$PATH` are tied -- assigning to one
# updates the other.
# shellcheck disable=SC2206
path=(
  "$HOME/bin"
  "$HOME/.local/bin"
  "$HOME/.nix-profile/bin"
  "/opt/homebrew/opt/grep/libexec/gnubin"
  "/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
  $path
)

# --- Editor ---
export EDITOR='code --wait'

# --- Locale ---
export LANG='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'

# --- Less ---
export MANPAGER='less -X'
export LESSHISTFILE="$XDG_STATE_HOME/less/history"

# --- Zsh history (relocated to XDG state) ---
export HISTFILE="$XDG_STATE_HOME/zsh/history"

# --- Node ---
export NODE_REPL_HISTORY="$XDG_STATE_HOME/node/history"
export NODE_REPL_HISTORY_SIZE='32768'
export NODE_REPL_MODE='sloppy'

# --- Python ---
export PYTHONIOENCODING='UTF-8'
export PYTHON_HISTORY="$XDG_STATE_HOME/python/history"

# --- psql ---
export PSQL_HISTORY="$XDG_STATE_HOME/psql/history"

# --- npm ---
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"

# --- Go ---
# GOPATH is the parent of bin/, not bin/ itself. Prior version
# (GOPATH=$HOME/go/bin combined with PATH entry ~/go/bin/bin) was a
# pair of bugs that partly cancelled.
export GOPATH="$HOME/go"
# shellcheck disable=SC2206
path=("$GOPATH/bin" $path)

# --- AWS ---
# Default profile; can be overridden in shell-local.zsh or by the env.
export AWS_PROFILE="${AWS_PROFILE:-govcloud-dev}"

# --- asdf ---
# ASDF_DATA_DIR is where shims and installs live. ASDF_DIR is where the
# asdf installation itself lives (completions, asdf.sh). For the default
# Homebrew/asdf install they are the same directory.
export ASDF_DATA_DIR="$HOME/.asdf"
export ASDF_DIR="${ASDF_DIR:-$ASDF_DATA_DIR}"
# shellcheck disable=SC2206
path=("$ASDF_DATA_DIR/shims" $path)

# --- SSH agent ---
# macOS's Keychain-backed ssh-agent publishes SSH_AUTH_SOCK at a path that
# changes every login session (/var/run/com.apple.launchd.<random>/...).
# Sandboxed tools (e.g. Claude Code) need a fixed path to allowlist, so
# keep a stable symlink that always points at the current live socket,
# and point every tool at the symlink instead of the volatile path.
#
# Guard against SSH_AUTH_SOCK already being the stable path itself (e.g.
# inherited from a parent shell that already did this rewrite): relinking
# it against itself would silently turn the symlink into a self-loop
# (ln -sf succeeds but breaks it), so only relink when the source differs.
_ssh_agent_stable_sock="$HOME/.ssh/agent.sock"
if [[ -n "$SSH_AUTH_SOCK" && "$SSH_AUTH_SOCK" != "$_ssh_agent_stable_sock" && -S "$SSH_AUTH_SOCK" ]]; then
  ln -sf "$SSH_AUTH_SOCK" "$_ssh_agent_stable_sock"
fi
[[ -S "$_ssh_agent_stable_sock" ]] && export SSH_AUTH_SOCK="$_ssh_agent_stable_sock"
unset _ssh_agent_stable_sock

# Re-export PATH once at the end. zsh ties `path` and `PATH` automatically,
# but a single explicit export documents the intent and covers any subshell
# weirdness.
export PATH
