function npm --wraps npm --description "Redirect global installs to bun"
    if contains -- -g $argv; or contains -- --global $argv
        set -l clean_args
        for arg in $argv
            switch $arg
                case -g --global install i
                    # skip these, bun will get its own flags
                case '*'
                    set -a clean_args $arg
            end
        end
        echo "Redirecting to: bun install -g $clean_args" >&2
        command bun install -g $clean_args
    else
        command npm $argv
    end
end
