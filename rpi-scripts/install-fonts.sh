#! /bin/bash
# Install patched Nerd Fonts (Hack + FiraCode) for the prompt glyphs.
# Note: apt's fonts-hack / fonts-firacode are the PLAIN fonts without Nerd glyphs,
# so we pull the patched release zips instead. Fonts are arch-independent (arm64 ok).
# https://github.com/ryanoasis/nerd-fonts
__WDIR=$(pwd)

FONTS=(Hack FiraCode)
DEST="$HOME/.local/share/fonts"
BASE="https://github.com/ryanoasis/nerd-fonts/releases/latest/download"

which unzip > /dev/null 2>&1 || sudo apt-get install -y unzip

mkdir -p "$DEST"
__TMP=$(mktemp -d)

for f in "${FONTS[@]}"; do
  echo "Installing ${f} Nerd Font..."
  curl -fL "${BASE}/${f}.zip" -o "${__TMP}/${f}.zip" && \
    unzip -oq "${__TMP}/${f}.zip" -d "${DEST}/${f}"
done

rm -rf "$__TMP"
fc-cache -f "$DEST"

echo "Installed Nerd Fonts:"
fc-list | grep -iE "hack|fira" | grep -i nerd | sort -u

cd "$__WDIR"
