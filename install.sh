#!/usr/bin/env bash

echo 'Hello, world!'
exit

### Install Ly DM ###

pushd src/ly
nix-shell -p zig glibc pam xorg.libxcb --command 'zig build'
# sudo su
# nix-shell -p zig glibc pam xorg.libxcb --command 'zig build installexe -D init_system=systemd'
popd
# sudo su
# systemctl disable lightdm.service
# systemctl enable ly.service

