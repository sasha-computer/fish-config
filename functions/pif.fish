function pif --description "Send command output to pi for help"
    argparse 'c/clipboard' 'h/help' -- $argv
    or return

    if set -q _flag_help
        echo "pif - Send command output to pi for help"
        echo ""
        echo "Usage:"
        echo "  pif                    Re-run last command, capture output, send to pi"
        echo "  pif -c                 Use clipboard content as context"
        echo "  pif <command...>       Run command, send to pi on failure"
        echo "  pif [message]          Custom prompt (default: 'fix this error')"
        return
    end

    # Clipboard mode
    if set -q _flag_clipboard
        set -l content (pbpaste)
        if test -z "$content"
            echo "Clipboard is empty."
            return 1
        end
        set -l last_cmd $history[1]
        set -l contextfile (mktemp /tmp/pif-context.XXXXXX)
        printf "I ran this command:\n\n\$ %s\n\nHere's the output:\n\n%s\n" "$last_cmd" "$content" >$contextfile
        pi @$contextfile "This command failed. Help me fix it."
        rm -f $contextfile
        return
    end

    # If args look like a command (not just a message), pass through to the binary
    if test (count $argv) -gt 0
        # Check if first arg is an executable
        if type -q $argv[1]; or test -f $argv[1]
            command pif $argv
            return $status
        end
    end

    # No args: re-run last command from fish history
    set -l last_cmd $history[1]
    if test -z "$last_cmd"
        echo "No command in history."
        return 1
    end

    set_color yellow
    echo "⟳ Re-running: $last_cmd"
    set_color normal

    # Split history entry into args and pass to binary pif
    command pif -y (string split ' ' -- $last_cmd)
    return $status
end
