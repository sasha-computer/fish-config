# Modern Unix toolchain config (sourced from config.fish)

# Interactive-only setup
if status is-interactive
    # Tool integrations
    # Handled by PatrickF1/fzf.fish plugin
    # fzf --fish | source
    zoxide init fish | source
    mcfly init fish | source

    # Compatibility aliases (safe defaults)
    alias cat 'bat --paging=never'
    alias ls 'eza --icons=auto --group-directories-first'
    alias ll 'eza -lah --git --icons=auto --group-directories-first'
    alias la 'eza -la --icons=auto --group-directories-first'
    alias tree 'eza --tree --icons=auto --level=2'
    alias du 'dust'
    alias df 'duf'
    alias px 'procs'

    # Optional higher-impact replacements (enable when ready)
    # alias grep 'rg'
    # alias find 'fd'
    # alias top 'btm'
    # alias ping 'gping'
    # alias dig 'doggo'
    # alias curl 'xh'
    # alias sed 'sd'
    # alias cut 'choose'
end
