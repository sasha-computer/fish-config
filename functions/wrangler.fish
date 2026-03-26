function wrangler --description "Cloudflare Wrangler CLI"
    # Ensure nvm node is in PATH
    if test -d "$NVM_DIR/versions/node"
        set -l node_bin (ls -1 $NVM_DIR/versions/node 2>/dev/null | tail -1)
        if test -n "$node_bin"
            set -gx PATH "$NVM_DIR/versions/node/$node_bin/bin" $PATH
        end
    end
    
    # Run actual wrangler
    ~/.bun/install/global/node_modules/wrangler/bin/wrangler.js $argv
end