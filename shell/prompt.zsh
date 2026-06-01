#!/usr/bin/env zsh
# shellcheck disable=all
# zsh-heavy: TRAPUSR1, ZLE, porcelain v2 parsing -- shellcheck cannot lint usefully.

setopt PROMPT_SUBST
if [[ $COLORTERM = gnome-* && $TERM = xterm ]] && infocmp gnome-256color >/dev/null 2>&1; then
	export TERM='gnome-256color';
elif infocmp xterm-256color >/dev/null 2>&1; then
	export TERM='xterm-256color';
fi;

if tput setaf 1 &> /dev/null; then
	tput sgr0;
	bold=$(tput bold);
	reset=$(tput sgr0);
	# Solarized colors, taken from http://git.io/solarized-colors.
	black=$(tput setaf 0);
	blue=$(tput setaf 33);
	cyan=$(tput setaf 37);
	green=$(tput setaf 64);
	orange=$(tput setaf 166);
	purple=$(tput setaf 125);
	red=$(tput setaf 124);
	violet=$(tput setaf 61);
	white=$(tput setaf 15);
	yellow=$(tput setaf 136);
else
	bold='';
	reset="\e[0m";
	black="\e[1;30m";
	blue="\e[1;34m";
	cyan="\e[1;36m";
	green="\e[1;32m";
	orange="\e[1;33m";
	purple="\e[1;35m";
	red="\e[1;31m";
	violet="\e[1;35m";
	white="\e[1;37m";
	yellow="\e[1;33m";
fi;

# --- Async git status -------------------------------------------------------
# Why async: in a large repo (e.g. deployment_tools), `git status` takes
# 100-300ms even with core.fsmonitor enabled. Running it synchronously in
# PROMPT_SUBST makes the prompt visibly lag between commands. Instead, the
# background subshell computes the git segment, writes the rendered string
# to a per-shell tmpfile, and signals SIGUSR1 to trigger `zle reset-prompt`.
#
# On chpwd we clear the cached segment so we never display the previous
# repo's branch. The first prompt after `cd` into a new repo shows no git
# segment until the background job finishes (usually under 300ms).
#
# Pairs with core.fsmonitor=true + core.untrackedcache=true in ~/.gitconfig.

typeset -g _PROMPT_GIT_STATUS=""
typeset -g _PROMPT_GIT_TMPFILE="${TMPDIR:-/tmp}/zsh-git-prompt-$$"
typeset -g _PROMPT_GIT_BUSY=0

_prompt_git_compute() {
	local dir=$1 parent_pid=$2
	cd -q -- "$dir" 2>/dev/null || {
		printf '%s\t\n' "$dir" > "$_PROMPT_GIT_TMPFILE"
		kill -USR1 "$parent_pid" 2>/dev/null
		return
	}

	# Not in a git work tree (or inside .git/): empty segment.
	if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1 \
		|| [[ $(git rev-parse --is-inside-git-dir 2>/dev/null) == true ]]; then
		printf '%s\t\n' "$dir" > "$_PROMPT_GIT_TMPFILE"
		kill -USR1 "$parent_pid" 2>/dev/null
		return
	fi

	local branch="" s="" line xy
	local has_staged=0 has_unstaged=0 has_untracked=0

	# Single git invocation replaces 7 separate calls from the old prompt_git.
	# porcelain=v2 emits headers (# branch.head ...) and one line per change:
	#   1 XY ...   = changed (X=index, Y=worktree)
	#   2 XY ...   = renamed/copied
	#   u XY ...   = unmerged
	#   ? path     = untracked
	while IFS= read -r line; do
		case $line in
			'# branch.head '*)
				branch=${line#'# branch.head '}
				;;
			'1 '*|'2 '*)
				xy=${line[3,4]}
				[[ ${xy[1]} != '.' ]] && has_staged=1
				[[ ${xy[2]} != '.' ]] && has_unstaged=1
				;;
			'u '*)
				has_staged=1
				has_unstaged=1
				;;
			'? '*)
				has_untracked=1
				;;
		esac
	done < <(git status --porcelain=v2 --branch --untracked-files=normal 2>/dev/null)

	# Detached HEAD: porcelain v2 emits "(detached)" -- substitute short SHA.
	if [[ -z $branch || $branch == '(detached)' ]]; then
		branch=$(git rev-parse --short HEAD 2>/dev/null) || branch='(unknown)'
	fi

	(( has_staged ))    && s+='+'
	(( has_unstaged ))  && s+='!'
	(( has_untracked )) && s+='?'

	# Stash indicator: separate call (git status doesn't surface this).
	if git rev-parse --verify --quiet refs/stash >/dev/null 2>&1; then
		s+='$'
	fi

	[[ -n $s ]] && s=" [${s}]"

	# Render with colors baked in (matches the call site that used to read
	# prompt_git "${white} on ${violet}" "${blue}").
	local rendered="${white} on ${violet}${branch}${blue}${s}"

	printf '%s\t%s\n' "$dir" "$rendered" > "$_PROMPT_GIT_TMPFILE"
	kill -USR1 "$parent_pid" 2>/dev/null
}

_prompt_git_kick() {
	(( _PROMPT_GIT_BUSY )) && return
	_PROMPT_GIT_BUSY=1
	_prompt_git_compute "$PWD" $$ &!
}

TRAPUSR1() {
	_PROMPT_GIT_BUSY=0
	[[ -r $_PROMPT_GIT_TMPFILE ]] || return
	local content dir rendered
	content=$(< "$_PROMPT_GIT_TMPFILE")
	rm -f "$_PROMPT_GIT_TMPFILE"
	dir=${content%%$'\t'*}
	rendered=${content#*$'\t'}
	if [[ $dir == $PWD ]]; then
		# Only redraw if the rendered status actually changed. zle
		# reset-prompt has geometry quirks when the prompt wraps (long
		# branch names in big repos), and the redraw can clobber the
		# blank line above the prompt. Most consecutive commands in
		# the same repo produce identical status -- skipping the
		# redraw for those avoids the issue entirely. Only the first
		# command after chpwd will trigger a redraw and possibly hit
		# the glitch.
		if [[ $_PROMPT_GIT_STATUS != $rendered ]]; then
			_PROMPT_GIT_STATUS=$rendered
			zle && zle reset-prompt
		fi
	else
		# Result is for an old PWD; kick a fresh compute for the current dir.
		_prompt_git_kick
	fi
}

_prompt_git_chpwd() {
	_PROMPT_GIT_STATUS=""
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd _prompt_git_kick
add-zsh-hook chpwd _prompt_git_chpwd

# Print a blank line before each prompt for visual separation between
# commands. This was previously done with a leading $'\n' inside PS1,
# but that put the recorded prompt-start position one line above the
# actual prompt content. Combined with Ghostty's OSC 133;A;cl=line
# fresh-line behavior, `zle reset-prompt` from TRAPUSR1 would clear
# into the previous command's output. Printing the blank line here,
# outside PS1, keeps the prompt-start position on the user-info line
# so reset-prompt can never touch the command output above.
_prompt_blank_line() { print; }
add-zsh-hook precmd _prompt_blank_line

# The default accept-line widget skips precmd when the buffer is
# empty, which means _prompt_blank_line above never runs for a bare
# Enter and there's no visual separation between successive prompts.
# Wrapping accept-line (even with a no-op body) forces the full
# command cycle including precmd, so _prompt_blank_line fires and we
# get the same blank line we get after a real command.
_prompt_accept_line() { zle .accept-line; }
zle -N accept-line _prompt_accept_line

# Backwards compat: anything else that calls prompt_git just gets the cached
# value. The PS1 below references $_PROMPT_GIT_STATUS directly.
function prompt_git() {
	print -nr -- "$_PROMPT_GIT_STATUS"
}

function aws_profile() {
  echo ${AWS_PROFILE}
}

# Highlight the user name when logged in as root.
if [[ "${USER}" == "root" ]]; then
	userStyle="${red}";
else
	userStyle="${orange}";
fi;

# Highlight the hostname when connected via SSH.
if [[ "${SSH_TTY}" ]]; then
	hostStyle="${bold}${red}";
else
	hostStyle="${yellow}";
fi;

# Set the terminal title and prompt.
# The blank line above the prompt is printed by the _prompt_blank_line
# precmd hook above -- do NOT add a leading $'\n' to PS1 (see comment
# there for why).
PS1="${bold}";
PS1+="${userStyle}%n"; # username
PS1+='${blue} (aws: $(aws_profile))';
PS1+="${white} at ";
PS1+="${hostStyle}%m"; # host
PS1+="${white} in ";
PS1+="${green}%~"; # working directory full path
PS1+='${_PROMPT_GIT_STATUS}'; # async-populated git segment
PS1+=$'\n';
PS1+="${white}$ ${reset}"; # `$` (and reset color)
export PS1;

PS2="${yellow}-> ${reset}";
export PS2;
