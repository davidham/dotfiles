#!/usr/bin/env zsh
# Aliases. Sourced by home/zshrc.zsh.
# shellcheck shell=bash

# --- Navigation ---
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ~="cd ~"
alias -- -="cd -"

# --- Shortcuts ---
alias d="cd ~/Documents/Dropbox"
alias dl="cd ~/Downloads"
alias dt="cd ~/Desktop"
alias p="cd ~/projects"
alias g="git"
alias h="history"
alias j="jobs"

# --- ls / grep color setup ---
# macOS ships BSD ls; GNU coreutils only present if user opted in via brew.
if ls --color > /dev/null 2>&1; then
  colorflag="--color"
  export LS_COLORS='no=00:fi=00:di=01;31:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=01;32:*.tar=01;31:*.tgz=01;31:*.zip=01;31:*.gz=01;31:*.bz2=01;31:*.jpg=01;35:*.png=01;35'
else
  colorflag="-G"
  export LSCOLORS='BxBxhxDxfxhxhxhxhxcxcx'
fi
alias l="ls -lF ${colorflag}"
alias la="ls -laF ${colorflag}"
alias lsd="ls -lF ${colorflag} | grep --color=never '^d'"
alias ls="command ls ${colorflag}"
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# --- Misc utility ---
alias sudo='sudo '
alias c="tr -d '\n' | pbcopy"
alias path='echo -e ${PATH//:/\\n}'
alias map="xargs -n1"
alias reload="exec $SHELL -l"
alias reload_dotfiles='~/dotfiles/install && source ~/.zshrc'

# --- Docker ---
alias dx='docker exec -it'
alias dc='docker compose'
alias dcx='docker compose exec'
alias dcr='docker compose run'

# --- Kubernetes ---
alias k='kubectl'
alias kc='kubectl config'
alias kctxt='kubectl config use-context'

# --- Terraform ---
alias tf='terraform'
alias ti='terraform init'
alias tg='terraform get'
alias tp='terraform plan -out tfplan'
alias ta='terraform apply tfplan && rm tfplan'

# --- AWS ---
alias aws_whoami='aws sts get-caller-identity'
alias login_aws='aws sso login'
alias fedaws='aws-vault exec govcloud-dev -- '

# --- Grafana ---
alias gcom-dev='~/grafana/deployment_tools/scripts/gcom/gcom-dev'
alias gcom-ops='~/grafana/deployment_tools/scripts/gcom/gcom-ops'
alias gcom='~/grafana/deployment_tools/scripts/gcom/gcom'

# --- Bazel: zsh auto-correction confuses bazel target paths ---
alias bazel='nocorrect bazel'
