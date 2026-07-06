# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# ---------- XDG base directories ----------
# Centralizes config/cache/data locations
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

# ---------- Editor ----------
# Default editor used by git, crontab, etc.
export EDITOR="nvim"
export VISUAL="nvim"

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# ZSH_THEME="robbyrussell"
ZSH_THEME="my-half-life"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# plugins=(
#   git
#   zsh-autosuggestions
#   zsh-syntax-highlighting
#   web-search
#   direnv
# )
# plugins=(git globalias)
plugins=(git)

source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

source $ZSH/oh-my-zsh.sh

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ~='cd ~'
alias -- -='cd -'          # go back to previous directory

# Listing
alias ll='ls -alF'
alias lt='ls -ltr'         # list by time, newest last

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

alias t="tmux"
alias n="nvim"
alias v="vim"

# Obsidian
alias oo="cd ~/Library/Mobile\ Documents/iCloud\~md\~obsidian/Documents/vegardga && nvim"

alias colimastart="colima start --profile rosetta --cpu 4 --memory 8 --disk 100 --arch aarch64 --vm-type=vz --vz-rosetta"

alias tailscale="/Applications/Tailscale.app/Contents/MacOS/Tailscale"

# Kubernetes
alias k='kubectl'

bindkey '^[[Z'      autosuggest-accept

# bindkey -v

HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000000
SAVEHIST=10000000

HISTORY_IGNORE="(ls|cd|pwd|exit|cd)*"

setopt EXTENDED_HISTORY      # Write the history file in the ':start:elapsed;command' format.
setopt INC_APPEND_HISTORY    # Write to the history file immediately, not when the shell exits.
#setopt SHARE_HISTORY         # Share history between all sessions.
setopt HIST_IGNORE_DUPS      # Do not record an event that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS  # Delete an old recorded event if a new event is a duplicate.
setopt HIST_IGNORE_SPACE     # Do not record an event starting with a space.
setopt HIST_SAVE_NO_DUPS     # Do not write a duplicate event to the history file.
setopt HIST_VERIFY           # Do not execute immediately upon history expansion.
setopt APPEND_HISTORY        # append to history file (Default)
setopt HIST_NO_STORE         # Don't store history commands
setopt HIST_REDUCE_BLANKS    # Remove superfluous blanks from each command line being added to the history.

HIST_STAMPS="yyyy-mm-dd"

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

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)
# eval "$(zoxide init zsh)"

alias java11="export JAVA_HOME=`/usr/libexec/java_home -v 11`; java -version"
alias java17="export JAVA_HOME=`/usr/libexec/java_home -v 17`; java -version"
alias java21="export JAVA_HOME=`/usr/libexec/java_home -v 21`; java -version"
export JAVA_HOME="/usr/libexec/java_home -v 17"

# ---------- PATH ----------
# Personal binaries/scripts
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.local/scripts:$PATH"

# postgres-stuff
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
export LDFLAGS="-L/opt/homebrew/opt/libpq/lib"
export CPPFLAGS="-I/opt/homebrew/opt/libpq/include"

# ---------- GPG ----------
export GPG_TTY=$(tty)

create_worktree() {
  local name="$1"
  if [[ -n "$name" ]]; then
    git worktree add -b "$name" ../"$name"
  fi
  return
}

worktree() {
  local name="$1"
  if [[ -n "$name" ]]; then
    git worktree add -b "$name" ../"$name"
    return
  fi
}

tmux-ai-cleanup() {
  local selection
  selection=$(tmux ls -F '#{session_name}' \
    | fzf --height=40% --reverse)  || return 0

  echo "$selection"
  git worktree remove "$selection"
  git worktree prune
  ai-cleanup "$selection"
  tmux kill-session -t "$selection"
}


# usage: ai [--no-state] [name [dir...]]
#   ai                          - fzf pick from all docker-ai-* containers
#   ai <name>                   - create/attach to docker-ai-<name>, mounts pwd
#   ai <name> <dir>             - create/attach to docker-ai-<name>, mounts dir
#   ai <name> <dir1> <dir2>...  - same, mounts multiple dirs; cwd is dir1
#   ai --no-state <name>        - same, but omits ai state mounts
#   ai --worktree
#   ai --tmux
#   ai --web-ui
ai-torgeir() {
  # prefer podman, fall back to docker
  local runtime
  if command -v podman &>/dev/null; then
    runtime=podman
  elif command -v docker &>/dev/null; then
    runtime=docker
  else
    echo "Neither docker nor podman found" >&2
    return 1
  fi

  # parse flags
  local no_state=0
  local create_worktree=0
  local create_cmd="exec /bin/bash"
  local -a start_cmd=(/bin/bash)
  local -a web_ui=()
  if [[ "$1" == "--no-state" ]]; then
    no_state=1
    shift
  fi

  # create worktree?
  if [[ "$1" == "--worktree" ]]; then
    create_worktree=1
    shift
  fi

  # run with tmux if enabled
  if [[ "$1" == "--tmux" ]]; then
    create_cmd="exec tmux"
    start_cmd=(tmux attach)
    shift
  fi
  # enable access to container through port 4040 if set
  if [[ "$1" == "--web-ui" ]]; then
    web_ui+=(-p "127.0.0.1:4040:4040")
    shift
  fi

  local name="$1"
  shift || true  # remaining args are dirs

  # collect dirs; default to pwd if none given
  local -a dirs=()
  for d in "$@"; do
    [[ "$d" = /* ]] && dirs+=("$d") || dirs+=("$PWD/$d")
  done

  # create and switch to worktree if flag set
  if (( create_worktree )); then
    worktree "$name"
    cd ../"$name"
  fi

  # mount pwd if no folder given
  if (( ${#dirs[@]} == 0 )); then
    dirs=("$PWD")
  fi

  # --userns=keep-id maps your host uid straight through inside the container
  # (batman uid == your uid), so bind mounts just work without chown tricks.
  # only podman supports this; docker gets no --userns flag.
  local -a userns_flags=()
  if [[ "$runtime" == "podman" ]]; then
    userns_flags=(--userns=keep-id)
  fi

  # amd gpu: /dev/kfd for rocm compute, /dev/dri for rendering
  local -a gpu_flags=()
  if [[ -e /dev/kfd ]] && [[ -e /dev/dri ]]; then
    gpu_flags=(--device /dev/kfd --device /dev/dri)
  fi
  # TODO nvidia

  # hardening defaults (drop linux capabilities and block privilege escalation)
  local -a security_flags=(--cap-drop=ALL --security-opt=no-new-privileges)

  # mount every requested dir; working dir is the first one
  local -a volumes=()
  for d in "${dirs[@]}"; do
    volumes+=(-v "${d}:${d}")
  done
  # set working directory to repo
  volumes+=(-w "${dirs[1]}")

  volumes+=(
    -v "$HOME/.m2:/home/batman/.m2"
    -v "$HOME/.gradle:/home/batman/.gradle"
    -v "$HOME/.gitconfig.docker-ai:/home/batman/.gitconfig.private:ro"
  )

  if (( !no_state )); then
    volumes+=(
      # opencode
      -v "$HOME/.local/share/opencode:/home/batman/.local/share/opencode"
      -v "$HOME/.local/state/opencode:/home/batman/.local/state/opencode"
      -v "$HOME/.config/opencode/opencode-ai.json:/home/batman/.config/opencode/opencode.json:ro"
    )
  fi

  # named container: create or attach
  if [[ -n "$name" ]]; then
    local container="docker-ai-$name"
    if $runtime ps --format '{{.Names}}' | grep -qx "$container"; then
      $runtime exec -it "$container" ${start_cmd[@]}
    elif $runtime ps -a --format '{{.Names}}' | grep -qx "$container"; then
      $runtime start "$container" && $runtime exec -it "$container" ${start_cmd[@]}
    else
      echo "Starting $container mounting: ${dirs[*]} ($runtime)"
      $runtime run -dit --name "$container" "${userns_flags[@]}" "${gpu_flags[@]}" "${security_flags[@]}" "${volumes[@]}" "${web_ui[@]}" docker-ai bash -c $create_cmd
      sleep 1
      $runtime exec -it "$container" ${start_cmd[@]}
    fi
    return
  fi

  # no args: pick from all docker-ai-* containers with fzf
  local selection
  selection=$($runtime ps -a --format '{{.Names}}\t{{.Status}}' \
    | grep '^docker-ai-' \
    | fzf --height=40% --reverse --header="container  status") || return 0

  local container
  container=$(echo "$selection" | awk '{print $1}')

  if $runtime start "$container"; then
    $runtime exec -it "$container" ${start_cmd[@]}
  else
    echo "Failed to start $container ($runtime)" >&2
    return 1
  fi
}

ai() {
  local -a volumes=()
  volumes+=(
    # -w "$PWD"
    # -v "$PWD":"$PWD"
    -w "/home/batman/workspace"
    -v "$PWD":"/home/batman/workspace"
    # -v "$HOME/.gitconfig.docker-ai:/home/batman/.gitconfig:ro"
    # -v "$HOME/.local/state/opencode:/home/batman/.local/state/opencode"
    # -v "$HOME/.config/opencode/opencode-ai.json:/home/batman/.config/opencode/opencode.json"
    -e OPENCODE_AUTH_TOKEN=$(op read op://domstol/opencode-auth-token/credential)
  )

  container_name="docker-ai-$1-$RANDOM"
  # container run -it --name "docker-ai-$1" "${volumes[@]}" base-opencode-auth
  # container run -it --name "$container_name" "${volumes[@]}" docker-ai-auth-tmux
  #
  container run -dit --name "$container_name" "${volumes[@]}" --cpus 4 --memory 8g docker-ai-auth-tmux bash -c "exec tmux"
  sleep 0.5
  container exec -it "$container_name" tmux attach
  #
  # podman run -it --name "$container_name" "${volumes[@]}" docker-ai-auth-tmux
  # podman run -dit --name "$container_name" "${volumes[@]}" docker-ai-auth-tmux bash -c "exec tmux"
  # sleep 0.5
  # podman exec -it "$container_name" tmux attach
  return
}

tmux-ai() {
  git worktree add ../"$1"

  tmux new-session -ds $1 -c "../$1"
  tmux send-keys -t $1 'nvim' C-m

  tmux new-window -n git -c "../$1" -t $1
  tmux send-keys -t $1 'lazygit' C-m

  tmux new-window -n console -c "../$1" -t $1

  tmux new-window -n ai -c "../$1" -t $1
  tmux send-keys -t $1 "ai $1" C-m

  tmux select-window -t "$1":1
  tmux switch-client -t $1
}
