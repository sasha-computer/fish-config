function email-search --description "Search emails with fzf"
    set -l db ~/Developer/emails/emails.db

    if not test -f $db
        echo "No email database at $db" >&2
        return 1
    end

    set -l count (sqlite3 $db "SELECT COUNT(*) FROM emails")

    # Phase 1: fzf with dynamic sqlite FTS5 search
    set -l result (
        sqlite3 -separator \t $db "SELECT id, COALESCE(substr(date,1,10),''), COALESCE(from_name,from_addr,''), subject FROM emails ORDER BY date DESC LIMIT 200" | \
        fzf \
            --ansi \
            --header "📧 $count emails · type to search · enter to view" \
            --prompt "email> " \
            --delimiter \t \
            --with-nth "2.." \
            --preview-window "right:50%:wrap" \
            --preview "sqlite3 -separator '' $db \"SELECT '📅 ' || COALESCE(date,'?') || x'0a' || '👤 ' || COALESCE(from_name,'') || ' <' || COALESCE(from_addr,'') || '>' || x'0a' || '📬 ' || COALESCE(to_addr,'') || x'0a' || '📋 ' || COALESCE(subject,'(no subject)') || x'0a' || x'0a' || COALESCE(substr(body,1,2000),'') FROM emails WHERE id = \" (echo {1})" \
            --bind "change:reload:sqlite3 -separator \t $db \"SELECT id, COALESCE(substr(date,1,10),''), COALESCE(from_name,from_addr,''), subject FROM emails WHERE CASE WHEN '{q}' = '' THEN 1 ELSE id IN (SELECT rowid FROM emails_fts WHERE emails_fts MATCH '\" (echo {q} | sed 's/[^a-zA-Z0-9@ .]/ /g' | sed 's/  */ /g' | sed 's/ /*  /g') \"*') END ORDER BY date DESC LIMIT 200\" 2>/dev/null || true"
    )

    # If user selected an email, show full body
    if test -n "$result"
        set -l email_id (echo $result | cut -f1)
        sqlite3 $db "SELECT '📅 ' || COALESCE(date,'') || char(10) || '👤 ' || COALESCE(from_name,'') || ' <' || COALESCE(from_addr,'') || '>' || char(10) || '📬 ' || COALESCE(to_addr,'') || char(10) || '📋 ' || COALESCE(subject,'(no subject)') || char(10) || char(10) || COALESCE(body,'') FROM emails WHERE id = $email_id" | less -R
    end

    commandline -f repaint
end
