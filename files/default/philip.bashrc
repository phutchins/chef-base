# Philip Hutchins .bashrc and .bash_profile

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# Determine what OS we're running on
unamestr=`uname`
if [[ "$unamestr" == 'Linux' ]]; then
   platform='linux'
   OS=$(lsb_release -si)
   ARCH=$(uname -m | sed 's/x86_//;s/i[3-6]86/32/')
   VER=$(lsb_release -sr)
elif [[ "$unamestr" == 'Darwin' ]]; then
   platform='osx'
fi

# Packages that I want installed
if [[ $platform == 'linux' ]]; then
  if [[ $OS == 'Ubuntu' ]]; then
    if ! [ "dpkg -l | grep tmux" ] ; then
      echo "Installing Tmux"
      sudo apt-get install tmux
    fi
  elif [[ $OS == 'CentOS' ]]; then
    if ! [ "yum list installed | grep tmux" ]; then
      echo "Installing Tmux"
      sudo yum install tmux
    fi
  fi
elif [[ $platform == 'osx' ]]; then
  if [ ! -f /usr/local/bin/brew ]; then
    ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"
  fi
  if [ ! -f /usr/local/bin/tmux ]; then
    brew install tmux
    brew install reattach-to-user-namespace
  fi
  # Export Docker Host IP
  export DOCKER_HOST=tcp://192.168.59.103:2375
fi

### History ###
# don't put duplicate lines in the history. See bash(1) for more options
# don't overwrite GNU Midnight Commander's setting of `ignorespace'.
#export HISTCONTROL=$HISTCONTROL${HISTCONTROL+,}ignoredups
# ... or force ignoredups and ignorespace
#export HISTCONTROL=ignoreboth
# append to the history file, don't overwrite it
#shopt -s histappend

HISTIGNORE="hnote*"
# Used to put notes in a history file
function hnote {
    echo "## NOTE [`date`]: $*" >> $HOME/.history/bash_history-`date +%Y%m%d`
}

# used to keep my history forever
PROMPT_COMMAND="[ -d $HOME/.history ] || mkdir -p $HOME/.history; echo : [\$(date)] $$ $USER \$OLDPWD\; \$(history 1 | sed -E 's/^[[:space:]]+[0-9]*[[:space:]]+//g') >> $HOME/.history/bash_history-\`date +%Y%m%d\`"

### Editor ###
export EDITOR=vim
set -o vi
bind '\C-a:beginning-of-line'
bind '\C-e:end-of-line'

### PATH ###
if [[ $platform == 'linux' ]]; then
  alias ls='ls --color=auto'
  export PATH=~/bin:/usr/local/bin:~/.local/bin:$PATH
elif [[ $platform == 'osx' ]]; then
  export JAVA_HOME=$(/usr/libexec/java_home)
  export PATH=~/bin:/usr/local/bin:~/Library/Python/2.7/bin:$PATH
  alias ls='ls -G'
fi

### Visual Settings ###
# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

### Include Files ###
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    eval "`dircolors -b`"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -l'
alias la='ls -A'
alias l='ls -CF'

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

### Prompt ###

export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting
