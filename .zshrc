# Load the shell dotfiles, and then some:
# * ~/.path can be used to extend `$PATH`.
# * ~/.extra can be used for other settings you don’t want to commit.
for file in ~/.{path,prompt,exports,aliases,functions,extra,secrets}; do
	[ -r "$file" ] && [ -f "$file" ] && source "$file";
done;
unset file;

setopt NO_CASE_GLOB

# Just enter the path you want, without `cd`
setopt AUTO_CD

# append completions to fpath
fpath=(${ASDF_DIR}/completions $fpath)

autoload -Uz compinit && compinit

# Save history when closing the window
HISTFILE=${ZDOTDIR:-$HOME}/.zsh_history
setopt EXTENDED_HISTORY

# share history across multiple zsh sessions
setopt SHARE_HISTORY
# append to history
setopt APPEND_HISTORY

# adds commands as they are typed, not at shell exit
setopt INC_APPEND_HISTORY

setopt CORRECT
setopt CORRECT_ALL


# https://asdf-vm.com/guide/getting-started.html#_3-install-asdf
. $HOME/.asdf/asdf.sh


export DIRENV_LOG_FORMAT="$(printf "\033[2mdirenv: %%s\033[0m")"
eval "$(direnv hook zsh)"
_direnv_hook() {
  eval "$(direnv export zsh 2> >(egrep -v -e '^....direnv: export' >&2))"
};
