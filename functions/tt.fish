function tt --description "Switch Ghostty theme with fzf preview"
    set -l config_file ~/.config/ghostty/config
    set -l builtin_dir /Applications/Ghostty.app/Contents/Resources/ghostty/themes
    set -l custom_dir ~/.config/ghostty/themes
    set -l preview_script ~/.config/fish/functions/_ghostty_theme_preview.sh

    if not test -f $config_file
        echo "No Ghostty config found at $config_file"
        return 1
    end

    # Get current theme
    set -l current_theme (grep -E '^theme\s*=' $config_file | head -1 | sed 's/^theme\s*=\s*//')

    # Build theme list: custom themes first (marked), then built-in
    set -l themes
    if test -d $custom_dir
        for f in $custom_dir/*
            set -a themes "★ "(basename $f)
        end
    end
    for f in $builtin_dir/*
        set -a themes "  "(basename $f)
    end

    # Run fzf with preview via external bash script
    set -l selection (printf '%s\n' $themes | fzf \
        --header="Current: $current_theme  │  ★ = custom  │  Enter = apply  │  Esc = cancel" \
        --preview="/bin/bash $preview_script {}" \
        --preview-window=right:45%:wrap \
        --query=(test -n "$argv[1]"; and echo $argv[1]; or echo "") \
        --height=80% \
        --border=rounded \
        --prompt="Theme > " \
        --ansi)

    if test -z "$selection"
        return 0
    end

    # Strip the prefix marker
    set -l theme_name (echo $selection | sed 's/^[★ ]* //')

    if test "$theme_name" = "$current_theme"
        echo "Already using '$theme_name'"
        return 0
    end

    # Update the config file
    if grep -qE '^theme\s*=' $config_file
        sed -i '' "s/^theme *=.*\$/theme = $theme_name/" $config_file
    else
        echo "theme = $theme_name" >> $config_file
    end

    # Trigger Ghostty config reload via cmd+shift+,
    osascript -e 'tell application "System Events" to tell process "Ghostty" to keystroke "," using {command down, shift down}' 2>/dev/null

    # Generate matching Pi TUI theme
    set -l theme_file ""
    set -l custom_path "$custom_dir/$theme_name"
    set -l builtin_path "$builtin_dir/$theme_name"
    if test -f "$custom_path"
        set theme_file "$custom_path"
    else if test -f "$builtin_path"
        set theme_file "$builtin_path"
    end

    if test -n "$theme_file"
        set -l pi_theme_dir ~/.pi/agent/themes
        set -l pi_settings ~/.pi/agent/settings.json
        set -l converter ~/.config/fish/functions/_ghostty_to_pi_theme.sh
        mkdir -p $pi_theme_dir
        /bin/bash $converter "ghostty-sync" "$theme_file" "$pi_theme_dir/ghostty-sync.json"

        # Set as active Pi theme
        if test -f "$pi_settings"
            sed -i '' 's/"theme": *"[^"]*"/"theme": "ghostty-sync"/' $pi_settings
        end
        echo "Switched to '$theme_name' ✓"
    else
        echo "Switched to '$theme_name' ✓"
    end
end
