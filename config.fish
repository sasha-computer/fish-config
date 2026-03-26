# Fish shell configuration
set fish_greeting

# Homebrew behavior
set -gx HOMEBREW_NO_AUTO_UPDATE 1
set -gx HOMEBREW_NO_INSTALL_CLEANUP 1
set -gx HOMEBREW_NO_ENV_HINTS 1

# Tool paths
set -gx BUN_INSTALL "$HOME/.bun"
fish_add_path -a "$BUN_INSTALL/bin"
fish_add_path -a "$HOME/.foundry/bin"
fish_add_path -a "$HOME/.risc0/bin"

if status is-interactive
    # Shell shortcuts

    alias cdd 'cd ~/Developer/'
    alias cc 'claude --allow-dangerously-skip-permissions'
    alias cfg 'cd ~/.config/fish && pi'

    if type -q zeditor
        alias 'z.' 'zeditor .'
    end

    # Git shortcuts
    alias gl 'git log --oneline'
    alias gcm 'git commit -m'
    alias gaa 'git add .'
    alias gs 'git status'
    alias gfp 'git fetch --prune'
    alias gpl 'git pull'
    alias gp 'git push'
    alias gc 'git checkout'
    alias gcb 'git checkout -b'
    alias gcl 'git clone'
    alias grv 'git remote -v'


    # Modern Unix aliases/integrations
    set -l modern_unix_config "$HOME/.config/fish/modern-unix.fish"
    if test -f "$modern_unix_config"
        source "$modern_unix_config"
    end
end

# nvm (Node Version Manager) setup
set -gx NVM_DIR "$HOME/.nvm"

# Use bass to source nvm.sh since it's a bash script
if test -s "/opt/homebrew/opt/nvm/nvm.sh"
    function nvm
        bass source "/opt/homebrew/opt/nvm/nvm.sh" -- ';' nvm $argv
    end
    
    # Auto-load default node version
    if test -d "$NVM_DIR/versions/node"
        set -l default_node (ls -1 $NVM_DIR/versions/node 2>/dev/null | tail -1)
        if test -n "$default_node"
            fish_add_path "$NVM_DIR/versions/node/$default_node/bin"
        end
    end
end

# AI Agent 1PW API Credentials Access
# Secret loaded from conf.d/secrets.fish (gitignored)
