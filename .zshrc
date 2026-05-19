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


# # https://asdf-vm.com/guide/getting-started.html#_3-install-asdf
# . $HOME/.asdf/asdf.sh

# DIRENV LOG_FORMAT comes before the hook setup
export DIRENV_LOG_FORMAT="$(printf "\033[2mdirenv: %%s\033[0m")"
export DIRENV_LOG_FORMAT=""

[[ -e ~/.zprofile ]] && emulate sh -c 'source ~/.zprofile'


# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/davidham/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/davidham/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/davidham/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/davidham/google-cloud-sdk/completion.zsh.inc'; fi

source <(apollo-cli completion zsh)

eval "$(direnv hook zsh)"
_direnv_hook() {
  eval "$(direnv export zsh 2> >(egrep -v -e '^....direnv: export' >&2))"
};
# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/davidham/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions
