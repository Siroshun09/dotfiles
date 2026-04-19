DOTFILE_PATH=$HOME/dotfiles

export PATH=$HOME/.local/go/bin:$PATH
export PATH=$HOME/.local/bin:$PATH
export PATH=$DOTFILE_PATH/scripts/mac/bin:$PATH
export PATH=$DOTFILE_PATH/scripts/mac/bin.local:$PATH

###########
# Options #
###########

autoload -Uz compinit; compinit -u
autoload -Uz colors; colors

HISTFILE=~/.zsh_history
HISTSIZE=1000
SAVESIZE=1000

setopt share_history
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt hist_save_no_dups
setopt inc_append_history
setopt auto_param_slash
setopt auto_param_keys
setopt mark_dirs
setopt print_eight_bit
setopt no_beep

zstyle ':completion:*:default' menu select=2
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

##########
# Prompt #
##########

prompt_precmd() {
  local dir="%F{11}%~%f "
  local time="%F{242}%D{%H:%M:%S}%f"
  local next="%F{238}>%f "

  local git=""
  local branch=$(git symbolic-ref --short HEAD 2>/dev/null)
  if [[ -n "$branch" ]]; then
    git="%{$fg[blue]%}($branch)%{$reset_color%} "
  fi

  PROMPT="${time} ${dir}${git}"$'\n'"${next}"
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd prompt_precmd

LOCAL_ZSHRC="$DOTFILE_PATH/.zshrc.local"
[[ -f "$LOCAL_ZSHRC" ]] && source "$LOCAL_ZSHRC"
