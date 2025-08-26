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
# ? casper-md5check causes grub to refuse to boot if it detects changes to the login process (required to change the DM to greetd)
systemctl disable casper-md5check # ! sudo
systemctl disable lightdm.service # ! sudo
if ! systemctl is-enabled greetd.service | grep -q 'enabled'; then
  systemctl enable greetd.service # ! sudo
fi
mkdir -p /etc/greetd # ! sudo
cp -f static/etc/greetd/conf.toml /etc/greetd # ! sudo
# ? pam_encryptfs can sometimes cause greetd to fail to boot, as they are incompatible; encryptfs is deprecated anyways
for file in /etc/pam.d/*; do
  sed -i.bak '/^(?!\s*#).*pam_encryptfs.so/s/^/# /' "$file" # ! sudo
done

echo -e '\e[1mDisabling startup splash screen...\e[0m'

sed -i.bak '/GRUB_CMDLINE_LINUX_DEFAULT/s/^.*$/GRUB_CMDLINE_LINUX_DEFAULT=""/' /etc/default/grub # ! sudo


