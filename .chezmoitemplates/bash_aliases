# ~/.bash_aliases
# shellcheck shell=bash

_serve-http() {
	local endpoint="127.0.0.1:8080"
	if [[ $1 =~ ^[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.*:[0-9]{2,5}$ ]]; then
		# if [[ $1 =~ .:[0-9]{2,5}$ ]]; then
		endpoint="$1"
	fi
	if docker run --rm --name serve-http -v "$(pwd)":/usr/share/nginx/html:ro -p "$endpoint":80 -d nginx:alpine; then
		echo "Nginx listening at $endpoint"
	fi
}

# don't follow wineprefix folder that has symlinks (e.g. to /), as this can burn cpu at least in ~
_fzf_compgen_path() {
	echo "$1"
	command find "$1" \
		-name .git -prune -o -name .hg -prune -o -name .svn -prune -o \( -type d -o -type f -o -type l \) \
		-a -not -path "$1" -print 2> /dev/null | command sed 's@^\./@@'
}

alias drop-history-from-current-shell='unset HISTFILE'
alias grep='grep --color=auto'
alias k='kubectl'
alias ls='ls --color=auto'
alias qrencode='qrencode -t ansiutf8'
alias serve-http='_serve-http'
# required, so we don't have to install kitty-terminfo on every host we visit
[[ "$TERM" == "xterm-kitty" ]] && alias ssh="TERM=xterm-256color ssh" 
alias vi='vim'

# load kubectl completions
_completion_loader kubectl

# assign kubectl's completion function _start_kubectl to k
complete -o default -F __start_kubectl k
