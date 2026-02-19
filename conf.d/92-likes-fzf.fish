if status is-interactive
    function likes-fzf-widget --description "Fuzzy search X likes"
        set -l result (x-likes-fzf 2>/dev/null)
        if test -n "$result"
            open "$result"
        end
        commandline -f repaint
    end

    bind \ex likes-fzf-widget
end
