# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=10000
HISTFILESIZE=20000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes
export PATH=/opt/chefdk/embedded/bin:$PATH

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

##My stuff

dockermachineeval() {
  eval "$(docker-machine env $1)"
}

alias machine=docker-machine
alias denv=dockermachineeval

__docker_machine_ps1 () {
    local format=${1:- [%s]}
    if test ${DOCKER_MACHINE_NAME}; then
        local status
        if test ${DOCKER_MACHINE_PS1_SHOWSTATUS:-false} = true; then
            status=$(docker-machine status ${DOCKER_MACHINE_NAME})
            case ${status} in
                Running)
                    status=' R'
                    ;;
                Stopping)
                    status=' R->S'
                    ;;
                Starting)
                    status=' S->R'
                    ;;
                Error|Timeout)
                    status=' E'
                    ;;
                *)
                    # Just consider everything elase as 'stopped'
                    status=' S'
                    ;;
            esac
        fi
        printf -- "${format}" "${DOCKER_MACHINE_NAME}${status}"
    fi
}

export PATH=$PATH:~/.composer/vendor/bin
#export PS1="\[\033[38;5;82m\]\w:\[$(tput sgr0)\]\[\033[38;5;15m\] \[$(tput sgr0)\]"
#source ~/git-completion.bash
eval "$(chef shell-init `basename $SHELL`)"

RESET="\[\033[0m\]"
RED="\[\033[0;31m\]"
GREEN="\[\033[01;32m\]"
BLUE="\[\033[01;34m\]"
YELLOW="\[\033[0;33m\]"
function parse_bash {
  PS_INFO="$GREEN\w$RESET"
  EXTRA_LEN=$(($(dirs -0|wc -c)+$(echo $(__git_ps1) | wc -c)+$(echo $(__docker_machine_ps1) | wc -c) + $(echo $(date +"[%H:%M:%S]") | wc -c)))
  PS_ALT="\[\033[\$((COLUMNS-$(echo $(__git_ps1) | wc -c)-$(echo $(date +"[%H:%M:%S]") | wc -c)-$(echo $(__docker_machine_ps1) | wc -c)))G\] $RED[\t]$YELLOW\$(__git_ps1)$BLUE\$(__docker_machine_ps1)"
  if (("$EXTRA_LEN" > "$COLUMNS")); then
    PS_ALT="\[\033[\$((COLUMNS-$(echo $(__git_ps1) | wc -c)-$(echo $(__docker_machine_ps1) | wc -c)))G\] $YELLOW\$(__git_ps1)$BLUE\$(__docker_machine_ps1)"
  fi
  PS1="${PS_INFO} ${PS_ALT}\n${RESET}\\W: "
}
PROMPT_COMMAND=parse_bash
export PS1
