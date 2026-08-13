if status is-interactive
    if test -f /home/symphony/.dircolors-resident-evil
        eval (dircolors -c /home/symphony/.dircolors-resident-evil)
    end

    alias ls='ls --color=auto'
    alias ll='ls -lah --group-directories-first --color=auto'
    alias la='ls -A --color=auto'
    alias re='/home/symphony/.local/bin/re-terminal-status status'
    alias threat='/home/symphony/.local/bin/re-terminal-status threat'
    alias lab='clear; /home/symphony/.local/bin/re-terminal-status; ls'

    if not set -q RE_TERMINAL_STATUS_SHOWN
        set -gx RE_TERMINAL_STATUS_SHOWN 1
        if test -x /home/symphony/.local/bin/re-terminal-status
            /home/symphony/.local/bin/re-terminal-status
        end
    end
end

function fish_greeting
end

function fish_prompt
    set -l last_status $status

    set_color brred
    printf '╭─◆ '
    set_color white
    printf '%s' $USER
    set_color brblack
    printf '@'
    set_color white
    printf '%s ' (hostname)
    set_color brcyan
    printf '%s' (prompt_pwd)

    set -l branch (command git branch --show-current 2>/dev/null)
    if test -n "$branch"
        set_color brgreen
        printf ' git:%s' $branch
    end

    if test $last_status -ne 0
        set_color brred
        printf ' [%s]' $last_status
    end

    set_color normal
    printf '\n'
    set_color brred
    printf '╰─▸ '
    set_color normal
end

function fish_right_prompt
    set -l last_status $status
    if test $last_status -eq 0
        set_color brblack
        printf 'contained '
        set_color brgreen
        printf '● '
    else
        set_color brred
        printf 'breach:%s ' $last_status
    end
    set_color brblack
    date '+%H:%M'
    set_color normal
end
