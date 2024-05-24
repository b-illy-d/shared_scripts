#!/bin/bash

for file in ~/shared_scripts/*.sh; do
  local f=$(basename $file)
  if [ $f == "install_scripts.sh" ]; then
    continue
  fi
  ln -s $file "~/shared_scripts/bin/${f%.sh}"
  chmod +x "~/shared_scripts/bin/${f%.sh}"
done

export PATH=$PATH:~/shared_scripts/bin
