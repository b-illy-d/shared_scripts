#!/bin/bash

for file in $HOME/shared_scripts/*.sh; do
  f=$(basename $file)
  f=${f%.sh}
  if [[ $f == "install_scripts" ]]; then
    continue
  fi
  if [ ! -d "$HOME/shared_scripts/bin" ]; then
    echo "Creating directory ~/shared_scripts/bin"
    mkdir "$HOME/shared_scripts/bin"
  fi
  if [ -f "$HOME/shared_scripts/bin/$f" ]; then
    echo "Removing existing $f"
    rm "$HOME/shared_scripts/bin/$f"
  fi
  echo "Linking $f"
  ln -s $file "$HOME/shared_scripts/bin/$f"
  chmod +x "$HOME/shared_scripts/bin/$f"
done

export PATH=$PATH:~/shared_scripts/bin
source $HOME/.bashrc
