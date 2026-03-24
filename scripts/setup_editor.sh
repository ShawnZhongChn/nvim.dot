#!/bin/bash
# Description: Ensure nvim is the default editor for Kitty and Shell.
# Created for: macOS with Homebrew installed nvim.

echo "Updating ~/.zshrc..."
if ! grep -q "alias vim='nvim'" ~/.zshrc; then
  printf "\n# Editor Configuration\nalias vim='nvim'\nalias vi='nvim'\nexport EDITOR='nvim'\nexport VISUAL='nvim'\n" >> ~/.zshrc
fi

KITTY_CONF="$HOME/.config/kitty/kitty.conf"
if [ -f "$KITTY_CONF" ]; then
  echo "Updating $KITTY_CONF..."
  if ! grep -q "env EDITOR=/opt/homebrew/bin/nvim" "$KITTY_CONF"; then
    printf "\n# Explicitly set editor for Kitty\nenv EDITOR=/opt/homebrew/bin/nvim\nenv VISUAL=/opt/homebrew/bin/nvim\n" >> "$KITTY_CONF"
  fi
fi

echo "Environment setup complete! Please restart your terminal."
