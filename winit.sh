#!/bin/bash

SRC=~/.winit/.ssh/config
DEST=~/.ssh/config

# Check if the destination file already exists
if [ -e "$DEST" ]; then
  # If it does, move it to a backup file
  mv "$DEST" "$DEST.bak"
fi

# Create the symlink
ln -s "$SRC" "$DEST"
