#!/bin/bash
# Convert a Ghostty theme file into a Pi TUI theme JSON
# Usage: _ghostty_to_pi_theme.sh <theme-name> <theme-file> <output-path>
set -euo pipefail

THEME_NAME="$1"
THEME_FILE="$2"
OUTPUT="$3"

get() { grep "^$1 " "$THEME_FILE" | head -1 | sed 's/.*= *//' ; }
pal() { grep "^palette *= *$1=#" "$THEME_FILE" | head -1 | sed 's/.*#/#/' ; }

bg=$(get background)
fg=$(get foreground)
cursor=$(get cursor-color)

# Palette colors
black=$(pal 0)
red=$(pal 1)
green=$(pal 2)
yellow=$(pal 3)
blue=$(pal 4)
magenta=$(pal 5)
cyan=$(pal 6)
white=$(pal 7)
bright_black=$(pal 8)
bright_red=$(pal 9)
bright_green=$(pal 10)
bright_yellow=$(pal 11)
bright_blue=$(pal 12)
bright_magenta=$(pal 13)
bright_cyan=$(pal 14)
bright_white=$(pal 15)

# Detect light vs dark by background luminance
hex_to_lum() {
    local hex="${1#\#}"
    local r=$((16#${hex:0:2}))
    local g=$((16#${hex:2:2}))
    local b=$((16#${hex:4:2}))
    echo $(( (r * 299 + g * 587 + b * 114) / 1000 ))
}

lum=$(hex_to_lum "$bg")
is_light=false
if [ "$lum" -gt 128 ]; then
    is_light=true
fi

# Blend two hex colors: blend <color> <target> <amount 0-100>
blend() {
    local c1="${1#\#}" c2="${2#\#}" amt="$3"
    local inv=$((100 - amt))
    local r=$(( (16#${c1:0:2} * inv + 16#${c2:0:2} * amt) / 100 ))
    local g=$(( (16#${c1:2:2} * inv + 16#${c2:2:2} * amt) / 100 ))
    local b=$(( (16#${c1:4:2} * inv + 16#${c2:4:2} * amt) / 100 ))
    printf "#%02x%02x%02x" "$r" "$g" "$b"
}

# Generate subtle background variants
if $is_light; then
    selected_bg=$(blend "$bg" "$blue" 15)
    user_msg_bg=$(blend "$bg" "$fg" 6)
    tool_pending_bg=$(blend "$bg" "$blue" 8)
    tool_success_bg=$(blend "$bg" "$green" 8)
    tool_error_bg=$(blend "$bg" "$red" 8)
    custom_msg_bg=$(blend "$bg" "$magenta" 8)
    export_page_bg=$(blend "$bg" "$fg" 2)
    export_card_bg="$bg"
    export_info_bg=$(blend "$bg" "$yellow" 10)
    muted=$(blend "$fg" "$bg" 35)
    dim=$(blend "$fg" "$bg" 25)
else
    selected_bg=$(blend "$bg" "$blue" 18)
    user_msg_bg=$(blend "$bg" "$fg" 8)
    tool_pending_bg=$(blend "$bg" "$blue" 10)
    tool_success_bg=$(blend "$bg" "$green" 10)
    tool_error_bg=$(blend "$bg" "$red" 10)
    custom_msg_bg=$(blend "$bg" "$magenta" 10)
    export_page_bg=$(blend "$bg" "$fg" 3)
    export_card_bg=$(blend "$bg" "$fg" 6)
    export_info_bg=$(blend "$bg" "$yellow" 12)
    muted=$(blend "$fg" "$bg" 30)
    dim=$(blend "$fg" "$bg" 45)
fi

border_muted=$(blend "$bg" "$fg" 25)

cat > "$OUTPUT" <<EOF
{
  "\$schema": "https://raw.githubusercontent.com/badlogic/pi-mono/main/packages/coding-agent/src/modes/interactive/theme/theme-schema.json",
  "name": "$THEME_NAME",
  "vars": {
    "bg": "$bg",
    "fg": "$fg",
    "red": "$red",
    "green": "$green",
    "yellow": "$yellow",
    "blue": "$blue",
    "magenta": "$magenta",
    "cyan": "$cyan",
    "brightRed": "$bright_red",
    "brightGreen": "$bright_green",
    "brightBlue": "$bright_blue",
    "brightCyan": "$bright_cyan",
    "brightMagenta": "$bright_magenta",
    "muted": "$muted",
    "dim": "$dim"
  },
  "colors": {
    "accent": "cyan",
    "border": "blue",
    "borderAccent": "brightCyan",
    "borderMuted": "$border_muted",
    "success": "green",
    "error": "red",
    "warning": "yellow",
    "muted": "muted",
    "dim": "dim",
    "text": "",
    "thinkingText": "muted",

    "selectedBg": "$selected_bg",
    "userMessageBg": "$user_msg_bg",
    "userMessageText": "",
    "customMessageBg": "$custom_msg_bg",
    "customMessageText": "",
    "customMessageLabel": "magenta",
    "toolPendingBg": "$tool_pending_bg",
    "toolSuccessBg": "$tool_success_bg",
    "toolErrorBg": "$tool_error_bg",
    "toolTitle": "",
    "toolOutput": "muted",

    "mdHeading": "yellow",
    "mdLink": "blue",
    "mdLinkUrl": "dim",
    "mdCode": "cyan",
    "mdCodeBlock": "green",
    "mdCodeBlockBorder": "muted",
    "mdQuote": "muted",
    "mdQuoteBorder": "muted",
    "mdHr": "muted",
    "mdListBullet": "cyan",

    "toolDiffAdded": "green",
    "toolDiffRemoved": "red",
    "toolDiffContext": "muted",

    "syntaxComment": "muted",
    "syntaxKeyword": "blue",
    "syntaxFunction": "yellow",
    "syntaxVariable": "brightCyan",
    "syntaxString": "green",
    "syntaxNumber": "magenta",
    "syntaxType": "cyan",
    "syntaxOperator": "dim",
    "syntaxPunctuation": "dim",

    "thinkingOff": "$border_muted",
    "thinkingMinimal": "muted",
    "thinkingLow": "blue",
    "thinkingMedium": "cyan",
    "thinkingHigh": "magenta",
    "thinkingXhigh": "brightMagenta",

    "bashMode": "green"
  },
  "export": {
    "pageBg": "$export_page_bg",
    "cardBg": "$export_card_bg",
    "infoBg": "$export_info_bg"
  }
}
EOF
