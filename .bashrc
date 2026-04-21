DOTFILE_PATH=$HOME/dotfiles

export PATH=$HOME/.local/go/bin:$PATH
export PATH=$HOME/.local/bin:$PATH
export PATH=$DOTFILE_PATH/scripts/linux/bin:$PATH
export PATH=$DOTFILE_PATH/scripts/linux/bin.local:$PATH

###########
# Options #
###########

if [[ -f /etc/bash_completion ]]; then
  source /etc/bash_completion
elif [[ -f /usr/local/share/bash-completion/bash_completion ]]; then
  source /usr/local/share/bash-completion/bash_completion
fi

HISTFILE=~/.bash_history
HISTSIZE=1000
HISTFILESIZE=1000
HISTCONTROL=ignorespace:ignoredups:erasedups

shopt -s histappend

##########
# Prompt #
##########

prompt_precmd() {
  local reset='\[\e[0m\]'
  local color_time='\[\e[38;5;242m\]'
  local color_dir='\[\e[38;5;11m\]'
  local color_git='\[\e[34m\]'
  local color_next='\[\e[38;5;238m\]'

  local name="${PROMPT_NAME_PREFIX}"
  local dir="${color_dir}\w${reset} "
  local time="${color_time}\t${reset}"
  local next="${color_next}>${reset} "

  local git=""
  local branch
  branch=$(git symbolic-ref --short HEAD 2>/dev/null)
  if [[ -n "$branch" ]]; then
    git="${color_git}(${branch})${reset} "
  fi

  PS1="${name}${time} ${dir}${git}"$'\n'"${next}"
}

PROMPT_COMMAND="history -a; history -n; prompt_precmd"

LOCAL_BASHRC="$DOTFILE_PATH/.bashrc.local"
[[ -f "$LOCAL_BASHRC" ]] && source "$LOCAL_BASHRC"
