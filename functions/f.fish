function f --description "Fuzzy-find and cd into any folder under home"
    set -l result (fd \
        --type d \
        --hidden \
        --max-depth 6 \
        --exclude .git \
        --exclude node_modules \
        --exclude .cache \
        --exclude Library \
        --exclude target \
        --exclude dist \
        --exclude build \
        --exclude __pycache__ \
        --exclude .npm \
        --exclude .yarn \
        --exclude ".Trash" \
        . ~ 2>/dev/null \
        | string replace "$HOME/" "" \
        | sort \
        | fzf \
            --prompt="~ ❯ " \
            --header="enter: cd" \
            --height=~50% \
            --layout=reverse \
            --scheme=path \
            --preview="eza --tree --icons=auto --level=2 --color=always $HOME/{} 2>/dev/null | head -50")

    test -z "$result"; and return 1
    cd ~/$result
    commandline -f repaint
end
