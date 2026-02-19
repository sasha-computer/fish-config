function zj --description "Launch Zellij with theme matching system appearance"
    set -l theme "catppuccin-latte"
    if defaults read -g AppleInterfaceStyle &>/dev/null
        set theme "catppuccin-macchiato"
    end

    sed -i '' "s/^theme .*/theme \"$theme\"/" ~/.config/zellij/config.kdl
    zellij $argv
end
