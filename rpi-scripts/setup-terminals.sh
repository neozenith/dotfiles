#! /bin/bash
# Point the Pi's terminals at the installed Nerd Fonts declaratively (no click-ops).
# Canonical configs live in dotfiles/terminal-configs and are symlinked into ~/.config.
# Run rpi-scripts/install-fonts.sh first so the font names resolve.
__WDIR=$(pwd)
DOTFILES="$HOME/dotfiles"
TC="$DOTFILES/terminal-configs"

# kitty — pure declarative config, symlink it.
mkdir -p ~/.config/kitty
ln -sfv "$TC/kitty.conf" ~/.config/kitty/kitty.conf

# terminator — ConfigObj file, symlink it.
mkdir -p ~/.config/terminator
ln -sfv "$TC/terminator.config" ~/.config/terminator/config

# LXTerminal rewrites its config on close, so a symlink would drift.
# Patch the font line in place instead (do this while LXTerminal is CLOSED,
# otherwise it overwrites the file on exit).
LXT=~/.config/lxterminal/lxterminal.conf
if [ -f "$LXT" ]; then
  sed -i 's/^fontname=.*/fontname=FiraCode Nerd Font Mono 11/' "$LXT"
  echo "Patched LXTerminal font: $(grep '^fontname=' "$LXT")"
fi

cd "$__WDIR"
