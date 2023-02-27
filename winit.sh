#!/bin/bash

safe_link () {

  SRC=$1
  DEST=$2

  if ! [[ -L "$DEST" ]]; then
    ln -sbf --suffix=".bak" $SRC $DEST
  else
    ln -sf $SRC $DEST
  fi

}

safe_link ~/.winit/.ssh/config ~/.ssh/config
safe_link ~/.winit/vim/vimrc ~/.vimrc
