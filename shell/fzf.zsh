#!/usr/bin/env zsh
# fzf shell integration. Sourced after env/aliases/functions.
# Provides Ctrl-R (history search) and Ctrl-T (file search), plus **<TAB>
# completion. Degrades cleanly if fzf is not installed.
# shellcheck shell=bash

if command -v fzf >/dev/null 2>&1; then
  fzf_prefix="$(brew --prefix 2>/dev/null)/opt/fzf/shell"
  if [[ -d $fzf_prefix ]]; then
    [[ -r "$fzf_prefix/key-bindings.zsh" ]] && source "$fzf_prefix/key-bindings.zsh"
    [[ -r "$fzf_prefix/completion.zsh" ]] && source "$fzf_prefix/completion.zsh"
  fi
  unset fzf_prefix

  # Use a nicer default command if rg or fd is installed.
  if command -v fd >/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  elif command -v rg >/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob !.git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  fi
fi
