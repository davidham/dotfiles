#!/usr/bin/env zsh
# Shell functions. Sourced by home/zshrc.zsh.
# shellcheck shell=bash

# Create a directory and cd into it.
mkd() {
  mkdir -p "$@" && cd "$_" || return
}

# cd to the directory of the front Finder window.
cdf() {
  cd "$(osascript -e 'tell app "Finder" to POSIX path of (insertion location as alias)')" || return
}

# Size of a file or total size of a directory.
fs() {
  local arg
  if du -b /dev/null > /dev/null 2>&1; then
    arg=-sbh
  else
    arg=-sh
  fi
  if [[ -n "$*" ]]; then
    du $arg -- "$@"
  else
    du $arg .[^.]* ./*
  fi
}

# Open in $EDITOR (vim if $EDITOR unset).
v() {
  if [ $# -eq 0 ]; then
    "${EDITOR:-vim}" .
  else
    "${EDITOR:-vim}" "$@"
  fi
}

# Open in default app.
o() {
  if [ $# -eq 0 ]; then
    open .
  else
    open "$@"
  fi
}

# Tree with sensible defaults piped through less.
tre() {
  tree -aC -I '.git|node_modules|bower_components' --dirsfirst "$@" | less -FRNX
}

# Aggregate kubeconfigs from ~/.kube/configs/ into KUBECONFIG.
# Previously ran kubectl config get-contexts at shell start (slow + noisy
# + auto-mkdir). Now: just set KUBECONFIG if the directory exists, no
# side effects.
load_kubeconfigs() {
  local configs_dir="$HOME/.kube/configs"
  [[ -d $configs_dir ]] || return 0
  local kubeconfigs=()
  local f
  for f in "$configs_dir"/*kubeconfig*(N); do
    kubeconfigs+=("$f")
  done
  if (( ${#kubeconfigs} > 0 )); then
    export KUBECONFIG="${(j.:.)kubeconfigs}${KUBECONFIG:+:$KUBECONFIG}"
  fi
}
load_kubeconfigs

# Set AWS_PROFILE.
profile() {
  export AWS_PROFILE=$1
}

# Pull a JSON secret out of AWS Secrets Manager.
download_secret() {
  local SECRET_NAME=$1
  local OUTPUT_FILE="${2:-secrets.json}"
  aws secretsmanager get-secret-value \
    --secret-id "${SECRET_NAME}" \
    | jq -S '.SecretString | fromjson' \
    > "$(pwd)/${OUTPUT_FILE}"
}

# Push a JSON secret to AWS Secrets Manager.
upload_secret() {
  local SECRET_NAME=$1
  local INPUT_FILE="${2:-secrets.json}"
  aws secretsmanager put-secret-value \
    --secret-id "${SECRET_NAME}" \
    --secret-string "file://$(pwd)/${INPUT_FILE}"
}

# Delete local branches not present at any remote.
# The commit-commands:clean_gone Claude skill is the recommended workflow
# alternative for "delete local branches whose upstream is gone." This
# function is broader: it deletes any local branch that has no remote
# counterpart, not just gone-upstream branches. Force-delete is used --
# review your branch list before running.
clean_branches() {
  local REMOTES="$*"
  if [ -z "$REMOTES" ]; then
    REMOTES=$(git remote)
  fi
  REMOTES=$(echo "$REMOTES" | xargs -n1 echo)
  local RBRANCHES=()
  while read -r REMOTE; do
    local CURRBRANCHES=()
    while IFS= read -r b; do
      CURRBRANCHES+=("$b")
    done < <(git ls-remote "$REMOTE" | awk '{print $2}' | grep 'refs/heads/' | sed 's:refs/heads/::')
    RBRANCHES=("${CURRBRANCHES[@]}" "${RBRANCHES[@]}")
  done < <(echo "$REMOTES")
  [[ ${#RBRANCHES[@]} -eq 0 ]] && return
  local LBRANCHES=()
  while IFS= read -r b; do
    LBRANCHES+=("$b")
  done < <(git branch | sed 's:\*::' | awk '{print $1}')
  local i j skip
  for i in "${LBRANCHES[@]}"; do
    skip=
    for j in "${RBRANCHES[@]}"; do
      if [[ "$i" == "$j" ]]; then
        skip=1
        printf '\033[32m Keeping %s \033[0m\n' "$i"
        break
      fi
    done
    [[ -n $skip ]] || printf '\033[31m %s \033[0m\n' "$(git branch -D "$i")"
  done
}
