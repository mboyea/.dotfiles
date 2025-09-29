#!/usr/bin/env bash

function t {
  return 0
}

function f {
  return 1
}

if [[ ! f ]]; then
  echo 'true'
fi

# if [[ $EUID -ne 0 ]]; then
#   echo -e '\e[1mThis installation script requires root privileges.\e[0m'
#   exec sudo bash "$0" "$@"
#   exit 1
# fi
# 
# echo user: $USER
# 
# echo sudo_user: $SUDO_USER

# exec sudo bash "$0" "$@"
# exit 1

