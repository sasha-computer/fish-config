function fzf_alias_picker --description "Fuzzy-pick an alias and insert it"
    if not type -q fzf
        echo "fzf_alias_picker: fzf is not installed"
        return 1
    end

    set -l lines (alias)

    # Also include fish functions (excluding builtins/internals)
    for fn in (functions --names)
        string match -q '_*' -- $fn; and continue
        string match -q 'fish_*' -- $fn; and continue

        # Try to extract --description from the function definition
        set -l body ""
        set -l desc_str (string match -r -- "--description '([^']+)'" (functions $fn 2>/dev/null))
        if test (count $desc_str) -ge 2
            set body $desc_str[2]
        else
            set -l fn_path (functions --details $fn 2>/dev/null)
            if test -n "$fn_path" -a "$fn_path" != "-"
                set body "($fn_path)"
            end
        end

        set -a lines "function $fn  $body"
    end

    if test (count $lines) -eq 0
        return 0
    end

    set -l out (printf "%s\n" $lines | fzf \
        --height=40% \
        --layout=reverse \
        --border \
        --print-query \
        --exit-0 \
        --prompt="alias/function> " \
        --header='Enter=insert, or type name="command" then Enter to create alias')

    if test (count $out) -eq 0
        return 0
    end

    set -l query (string trim -- $out[1])
    set -l picked ""
    if test (count $out) -ge 2
        set picked $out[2]
    end

    if test -n "$picked"
        set -l name
        if string match -q 'function *' -- $picked
            set name (string replace -r '^function ([^ ]+).*$' '$1' -- $picked)
        else
            set name (string replace -r '^alias ([^ ]+).*$' '$1' -- $picked)
        end
        commandline -i "$name "
        return 0
    end

    if test -z "$query"
        return 0
    end

    set -l spec (string trim -- $query)
    set spec (string replace -r '^alias[[:space:]]+' '' -- $spec)

    set -l groups (string match -r --groups-only '^([A-Za-z_][A-Za-z0-9_.-]*)=(.+)$' -- $spec)
    if test (count $groups) -ne 2
        echo 'fzf_alias_picker: use name="command", e.g. gpl="git pull"'
        return 1
    end

    set -l alias_name (string trim -- $groups[1])
    set -l alias_def (string trim -- $groups[2])

    set -l first_char (string sub -s 1 -l 1 -- "$alias_def")
    set -l last_char (string sub -s -1 -- "$alias_def")
    if test (string length -- "$alias_def") -ge 2
        if test "$first_char" = "'" -a "$last_char" = "'"
            set alias_def (string sub -s 2 -l (math (string length -- "$alias_def") - 2) -- "$alias_def")
        else if test "$first_char" = '"' -a "$last_char" = '"'
            set alias_def (string sub -s 2 -l (math (string length -- "$alias_def") - 2) -- "$alias_def")
        end
    end

    if test -z "$alias_def"
        echo "fzf_alias_picker: alias definition cannot be empty"
        return 1
    end

    set -l alias_name_re (string escape --style=regex -- "$alias_name")
    set -l existing_alias (alias | string match -r "^alias[[:space:]]+$alias_name_re([[:space:]]|=).*")
    if test (count $existing_alias) -gt 0
        read -l -P "Alias '$alias_name' exists. Overwrite? [y/N] " confirm
        set confirm (string lower -- (string trim -- "$confirm"))
        if test "$confirm" != "y" -a "$confirm" != "yes"
            echo "Cancelled: kept existing alias '$alias_name'"
            return 0
        end
    end

    alias --save "$alias_name" "$alias_def"
    or return 1

    commandline -i "$alias_name "
    echo "Saved alias: $alias_name -> $alias_def"
end
