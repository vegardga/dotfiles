# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# =========================================================
# XDG base directories
# =========================================================

# Centralizes config/cache/data locations
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

# =========================================================
# Editor
# =========================================================

# Default editor used by git, crontab, etc.
export EDITOR="nvim"
export VISUAL="nvim"
export LANG="no_NO.UTF-8"


# =========================================================
# Completion
# =========================================================

# Load completion system
autoload -Uz compinit

# Initialize completion with cached metadata file
compinit -d "$XDG_CACHE_HOME/zsh/zcompdump"

# Enable interactive completion menu selection
zstyle ':completion:*' menu select

# Make completion case-insensitive
# Example: "doc" can complete to "Documents"
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'  # lowercase input matches upper and lower

autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats '%b '
setopt PROMPT_SUBST

bindkey '^[[Z'      autosuggest-accept


# =========================================================
# Aliases
# =========================================================

# Navigation
alias ..='cd ..'
alias ...='cd ../..'

# Listing
alias ll='ls -alF'
alias lt='ls -ltr' # list by time, newest last

# Safety net (ask before overwriting)
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Docker shortcuts
alias dps='docker ps'
alias dc='docker-compose'
alias dcu="docker compose up -d $1"
alias dcd='docker-compose down'

# Reload shell config after editing
alias reload='source ~/.zshrc'

# tmux and vim
alias t="tmux"
alias n="nvim"
alias v="vim"

# Colima
alias colimastart="colima start --profile rosetta --cpu 4 --memory 8 --disk 100 --arch aarch64 --vm-type=vz --vz-rosetta"

# Kubernetes
alias k='kubectl'


# =========================================================
# History
# =========================================================

HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000000
SAVEHIST=10000000
HISTORY_IGNORE="(ls|cd|pwd|exit|cd)*"
HIST_STAMPS="yyyy-mm-dd"

setopt EXTENDED_HISTORY      # Write the history file in the ':start:elapsed;command' format.
setopt INC_APPEND_HISTORY    # Write to the history file immediately, not when the shell exits.
setopt SHARE_HISTORY         # Share history between all sessions.
setopt HIST_IGNORE_DUPS      # Do not record an event that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS  # Delete an old recorded event if a new event is a duplicate.
setopt HIST_IGNORE_SPACE     # Do not record an event starting with a space.
setopt HIST_SAVE_NO_DUPS     # Do not write a duplicate event to the history file.
setopt HIST_VERIFY           # Do not execute immediately upon history expansion.
setopt APPEND_HISTORY        # append to history file (Default)
setopt HIST_NO_STORE         # Don't store history commands
setopt HIST_REDUCE_BLANKS    # Remove superfluous blanks from each command line being added to the history.

# =========================================================
# Shell behaviour
# =========================================================

setopt AUTOCD
setopt NOBEEP
setopt NUMERIC_GLOB_SORT  # sort file10 after file9, not after file1


# =========================================================
# Functions
# =========================================================

# Function to jump to the root of the current Git repository
# Usage: `gr` (git root)
function gitroot() {
  local git_root=$(git rev-parse --show-toplevel 2>/dev/null)
  if [ -n "$git_root" ]; then
    cd "$git_root"
    echo "Moved to Git root: $(pwd)"
  else
    echo "Not in a Git repository." >&2
  fi
}

function gitrepo {
    local gitFolder=$(_gitFolder)
    if [ -z "$gitFolder" ]
    then
        echo "This could not find git folder" && return
    fi
    local git_url=$(_gitUrl)
    local url=${git_url%.git}
    open $url
}

_gitFolder() {
    while [ ! -d ".git" -a / != "$PWD" ]; do cd .. ;done; [ / != "$PWD" ] && echo $PWD || echo ''
}

_gitUrl() {
    local git_url="git config --get remote.origin.url"
    local git_url=$(sed 's/git@github.com:/https:\/\/github.com\//' <<< $git_url)
    echo $git_url
}

function pkill() {
  ps aux | fzf --height 40% --layout=reverse --prompt="Select process to kill: " | awk '{print $2}' | xargs -r sudo kill
}

function logg() {
    git lg | fzf --ansi --no-sort \
        --preview 'echo {} | grep -o "[a-f0-9]\{7\}" | head -1 | xargs -I % git show % --color=always' \
        --preview-window=right:50%:wrap --height 100% \
        --bind 'enter:execute(echo {} | grep -o "[a-f0-9]\{7\}" | head -1 | xargs -I % sh -c "git show % | nvim -c \"setlocal buftype=nofile bufhidden=wipe noswapfile nowrap\" -c \"nnoremap <buffer> q :q!<CR>\" -")' \
        --bind 'ctrl-e:execute(echo {} | grep -o "[a-f0-9]\{7\}" | head -1 | xargs -I % sh -c "gh browse %")'
}

worktree() {
  local name="$1"
  if [[ -n "$name" ]]; then
    git worktree add -b "$name" "../$name"
    cd "../$name"
    return
  fi
}


# =========================================================
# Path
# =========================================================

# Personal binaries/scripts
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.local/scripts:$PATH"

# postgres-stuff
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
export LDFLAGS="-L/opt/homebrew/opt/libpq/lib"
export CPPFLAGS="-I/opt/homebrew/opt/libpq/include"


# =========================================================
# GPG
# =========================================================

export GPG_TTY=$(tty)


# =========================================================
# zsh plugins
# =========================================================

# load zsh plugins
for plug in \
  $HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh \
  $HOME/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh;
do
  if [[ -f $plug ]]; then
    #echo "Loading plugin $plug"
    source $plug
  fi
done
