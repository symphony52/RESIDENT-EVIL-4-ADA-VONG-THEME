#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'

if [[ -f /home/symphony/.dircolors-resident-evil ]]; then
    eval "$(dircolors -b /home/symphony/.dircolors-resident-evil)"
fi

if [[ $TERM == xterm* || $TERM == konsole* || $TERM == screen* || $TERM == tmux* ]]; then
    export TERM=xterm-256color
fi

alias ll='ls -lah --group-directories-first --color=auto'
alias la='ls -A --color=auto'
alias cls='clear'

__re_prompt_git() {
    command git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return
    local branch
    branch=$(git branch --show-current 2>/dev/null)
    [[ -n $branch ]] && printf ' \[\e[38;5;118m\]git:%s\[\e[0m\]' "$branch"
}

if [[ -z ${RE_TERMINAL_STATUS_SHOWN:-} && -x /home/symphony/.local/bin/re-terminal-status ]]; then
    export RE_TERMINAL_STATUS_SHOWN=1
    /home/symphony/.local/bin/re-terminal-status
fi

alias re='RE_STATUS_ANIMATE=1 re-terminal-status status'
alias threat='RE_STATUS_ANIMATE=1 re-terminal-status threat'

PS1='\[\e[38;5;196m\]╭─◆ \[\e[38;5;255m\]\u\[\e[38;5;238m\]@\[\e[38;5;255m\]\h \[\e[38;5;45m\]\w\[\e[0m\]$(__re_prompt_git)\n\[\e[38;5;196m\]╰─▸ \[\e[0m\]'
export PATH="/home/symphony/.local/bin:$PATH"
