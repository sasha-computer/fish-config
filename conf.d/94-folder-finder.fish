# Ctrl+F: fuzzy-find and cd into any folder under home
if status is-interactive
    bind \cf 'f; commandline -f repaint'
    bind --mode insert \cf 'f; commandline -f repaint'
end
