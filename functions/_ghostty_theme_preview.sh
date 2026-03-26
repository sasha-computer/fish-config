#!/bin/bash
# Preview script for ghostty-theme fzf picker
theme="$1"
theme=$(echo "$theme" | sed 's/^[★ ]* //')
custom="$HOME/.config/ghostty/themes/$theme"
builtin="/Applications/Ghostty.app/Contents/Resources/ghostty/themes/$theme"

if [ -f "$custom" ]; then
    file="$custom"
    echo "📁 Custom theme"
elif [ -f "$builtin" ]; then
    file="$builtin"
    echo "📦 Built-in theme"
else
    echo "Theme file not found"
    exit 0
fi

echo ""
bg=$(grep "^background" "$file" | head -1 | sed "s/.*= *//")
fg=$(grep "^foreground" "$file" | head -1 | sed "s/.*= *//")
cursor=$(grep "^cursor-color" "$file" | head -1 | sed "s/.*= *//")
echo "  Background: $bg"
echo "  Foreground: $fg"
echo "  Cursor:     $cursor"
echo ""
echo "  ── Palette ──"
for i in $(seq 0 15); do
    hex=$(grep "^palette *= *$i=#" "$file" | sed "s/.*=.*#//" | head -1)
    if [ -n "$hex" ]; then
        r=$((16#${hex:0:2}))
        g=$((16#${hex:2:2}))
        b=$((16#${hex:4:2}))
        printf "  \033[48;2;%d;%d;%dm    \033[0m %2d: #%s\n" "$r" "$g" "$b" "$i" "$hex"
    fi
done
echo ""
if [ -n "$bg" ]; then
    bghex=$(echo "$bg" | sed "s/#//")
    r=$((16#${bghex:0:2})); g=$((16#${bghex:2:2})); b=$((16#${bghex:4:2}))
    printf "  BG: \033[48;2;%d;%d;%dm          \033[0m" "$r" "$g" "$b"
fi
if [ -n "$fg" ]; then
    fghex=$(echo "$fg" | sed "s/#//")
    r=$((16#${fghex:0:2})); g=$((16#${fghex:2:2})); b=$((16#${fghex:4:2}))
    printf "  FG: \033[48;2;%d;%d;%dm          \033[0m\n" "$r" "$g" "$b"
fi
