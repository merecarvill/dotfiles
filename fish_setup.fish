#!/bin/fish

if ! type -q omf
  curl -L https://get.oh-my.fish | fish
end

if ! type -q nvm
  omf install nvm

  nvm install --lts
  nvm use default
end
