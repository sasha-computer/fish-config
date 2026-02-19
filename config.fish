# Fish shell configuration
set fish_greeting

# Homebrew behavior
set -gx HOMEBREW_NO_AUTO_UPDATE 1
set -gx HOMEBREW_NO_INSTALL_CLEANUP 1
set -gx HOMEBREW_NO_ENV_HINTS 1

# Tool paths
set -gx BUN_INSTALL "$HOME/.bun"
fish_add_path -a "$HOME/.lmstudio/bin"
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


    # Boundless CLI dev build (run from repo checkout)
    alias boundless-dev 'cargo run --manifest-path ~/Developer/boundless/Cargo.toml --bin boundless --'

    # Modern Unix aliases/integrations
    set -l modern_unix_config "$HOME/.config/fish/modern-unix.fish"
    if test -f "$modern_unix_config"
        source "$modern_unix_config"
    end

    # try workspace manager
    if type -q try
        eval (try init ~/Developer/experiments | string collect)
    end
end

# Obsidian vault location
set -gx OBSIDIAN_VAULT ~/Documents/2026

# AI Agent 1PW API Credentials Access
# Secret loaded from conf.d/secrets.fish (gitignored)
