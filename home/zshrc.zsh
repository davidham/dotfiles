#!/usr/bin/env zsh
# Entrypoint. Symlinked to ~/.zshrc by Dotbot.

# Resolve the repo's shell/ dir. ${(%):-%N} is the path of the file
# being sourced (works in .zshrc where $0 is just "zsh"); :A resolves
# symlinks; :h takes the parent directory.
_DOTFILES_SHELL_DIR="${${(%):-%N}:A:h:h}/shell"

# Source order matters: env.zsh first (PATH, EDITOR, XDG vars), then
# everything else.
for module in env aliases functions prompt fzf; do
  module_path="${_DOTFILES_SHELL_DIR}/${module}.zsh"
  [[ -r $module_path ]] && source "$module_path"
done
unset module module_path

# Machine-local override (gitignored). Sourced last so it can override
# anything above.
local_override="${XDG_CONFIG_HOME:-$HOME/.config}/shell-local.zsh"
[[ -r $local_override ]] && source "$local_override"
unset local_override

setopt NO_CASE_GLOB
setopt AUTO_CD

# Augment fpath BEFORE compinit so all completion files are picked up.
if [ -d "$ASDF_DIR/completions" ]; then
  fpath=("$ASDF_DIR/completions" $fpath)
fi
if [ -d "$HOME/.docker/completions" ]; then
  fpath=("$HOME/.docker/completions" $fpath)
fi

autoload -Uz compinit
compinit -d "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"

setopt EXTENDED_HISTORY
setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt CORRECT
setopt CORRECT_ALL

# Silence direnv output (empty format string suppresses all log lines).
# Must be set before the direnv hook runs.
export DIRENV_LOG_FORMAT=""

[[ -e ~/.zprofile ]] && emulate sh -c 'source ~/.zprofile'

# Google Cloud SDK -- only if installed at the conventional $HOME location.
if [ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]; then
  . "$HOME/google-cloud-sdk/path.zsh.inc"
fi
if [ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]; then
  . "$HOME/google-cloud-sdk/completion.zsh.inc"
fi

# Apollo CLI (Grafana internal tool) -- only if installed.
if command -v apollo-cli >/dev/null 2>&1; then
  source <(apollo-cli completion zsh)
fi

# direnv -- only if installed.
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
  _direnv_hook() {
    eval "$(direnv export zsh 2> >(grep -E -v -e '^....direnv: export' >&2))"
  }
fi
