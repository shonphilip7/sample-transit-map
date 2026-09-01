#!/bin/bash
set -e
# Target existing directory
FONT_DIR="/src/fonts"
# List of font URLs
FONTS=(
    https://gwern.net/static/font/noto-emoji/NotoEmoji-Regular.ttf
    https://gwern.net/static/font/noto-emoji/NotoEmoji-Bold.ttf
    https://github.com/tony/dot-fonts/raw/refs/heads/master/Hanazono/HanaMinA.ttf
    https://github.com/tony/dot-fonts/raw/refs/heads/master/Hanazono/HanaMinB.ttf
)
for url in "${FONTS[@]}"; do
    echo "Downloading $(basename "$url")..."
    curl -sSL "$url" -o "$FONT_DIR/$(basename "$url")"
done