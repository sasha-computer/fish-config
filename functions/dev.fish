function dev --description "Fuzzy-find and cd into ~/Developer projects. Enter opens pi, Ctrl+P just cd's."
    set -l base ~/Developer

    # Gather top-level dirs + experiments/ subdirs
    set -l dirs
    for d in $base/*/
        set -l name (basename $d)
        test $name = experiments; and continue
        set -a dirs $name
    end
    for d in $base/experiments/*/
        set -l name (basename $d)
        set -a dirs "experiments/$name"
    end

    # If an argument was passed, use it as the initial query
    set -l query ""
    if test (count $argv) -gt 0
        set query $argv[1]
    end

    set -l result (printf '%s\n' $dirs | sort | fzf \
        --expect=ctrl-p \
        --query="$query" \
        --prompt="dev ❯ " \
        --header="enter: cd + pi  |  ctrl-p: cd" \
        --height=~40% \
        --layout=reverse \
        --scheme=path)

    test -z "$result"; and return 1

    # result is a fish list: first element is the key pressed, second is the pick
    set -l lines (string split \n -- $result)
    set -l key $lines[1]
    set -l pick $lines[2]

    test -z "$pick"; and return 1

    cd "$base/$pick"

    if test "$key" != ctrl-p
        pi
    end
end
