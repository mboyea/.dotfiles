#!/usr/bin/env bash

echo 'TODO: remove early exit'
exit

# TODO: sudo su

echo -e '\e[1mUpdating package cache...\e[0m'
apt update # ! sudo

echo -e '\e[1mInstalling greetd+tuigreet...\e[0m'

nix-shell -p cargo --command 'cargo build --release --targetdir src/tuigreet'
cp -f src/tuigreet/target/release/tuigreet /usr/local/bin/ # ! sudo
apt install greetd # ! sudo
systemctl disable casper-md5check # ! sudo
systemctl disable lightdm.service # ! sudo
if ! systemctl is-enabled greetd.service | grep -q 'enabled'; then
  systemctl enable greetd.service # ! sudo
fi
mkdir -p /etc/greetd # ! sudo
cp -f static/etc/greetd/conf.toml /etc/greetd # ! sudo
for file in /etc/pam.d/*; do
  sed -i.bak '/^(?!\s*#).*pam_encryptfs.so/s/^/# /' "$file" # ! sudo
done

