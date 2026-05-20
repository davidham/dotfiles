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
# Order: most-specific first. /opt/homebrew/bin comes from `brew shellenv`
# in ~/.zprofile and is not duplicated here.
path=(
  "$HOME/bin"
  "$HOME/.local/bin"
  "$HOME/.nix-profile/bin"
  "/opt/homebrew/opt/grep/libexec/gnubin"
  "/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
  $path
)
export PATH

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
path=("$GOPATH/bin" $path)
export PATH

# --- Docker ---
export DOCKER_DEFAULT_PLATFORM=linux/amd64

# --- AWS ---
export AWS_PROFILE=govcloud-dev

# --- asdf ---
export ASDF_DATA_DIR="$HOME/.asdf"
path=("$ASDF_DATA_DIR/shims" $path)
export PATH
