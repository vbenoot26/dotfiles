# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
 source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

if [[ -f "/opt/homebrew/bin/brew" ]] then
  # If you're using macOS, you'll want this enabled
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Add in Powerlevel10k
zinit ice depth=1; zinit light romkatv/powerlevel10k

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Add in snippets
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::aws
zinit snippet OMZP::kubectl
zinit snippet OMZP::kubectx
zinit snippet OMZP::command-not-found

# Load completions
autoload -Uz compinit && compinit

zinit cdreplay -q

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Keybindings
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region
bindkey -s ^f "tmux-sessionizer\n"

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Aliases
alias ls='ls --color'
alias vim='nvim'
alias c='clear'
alias v='nvim .'
alias uit='shutdown -h now'
alias l='ls -lah'
alias mt='make test'
alias ml='make lint'
alias gotest='opencode run --agent gotest "Write tests for the latest commit"'
#antlr
# alias antlr4='java -jar ~/ANTLR/antlr-4.13.1-complete.jar'
# alias grun='java org.antlr.v4.gui.TestRig'

mkcd() {
    mkdir "$1" && z "$1"
}
eval "$(zoxide init zsh)"

PATH="$PATH":"$HOME/scripts/"
PATH="$PATH":"$HOME/lua/lua-5.4.8/" 
PATH="$PATH":"$HOME/.local/bin" 
PATH="$PATH":"$HOME/go/bin"
PATH="$PATH":"$HOME/.cargo/bin"

GOFLAGS="-tags=test"

export BWS_ACCESS_TOKEN=$(security find-generic-password -a "$USER" -s "bws-access-token" -w 2>/dev/null)

export EDITOR=hx
export GIT_EDITOR=hx
export DOCKER_HOST="$(docker context inspect -f='{{.Endpoints.docker.Host}}')"
source /Users/vincentbenoot/.safe-chain/scripts/init-posix.sh # Safe-chain Zsh initialization script

prc() {
  gh pr create -l no-changelog || return
  local url
  url=$(gh pr view --json url -q .url) || return
  printf '%s' "$url" | pbcopy
  echo "Copied: $url"
}
