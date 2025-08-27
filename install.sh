#!/usr/bin/env bash

if [[ $EUID -ne 0 ]]; then
  echo -e '\e[1mThis installation script requires root privileges.\e[0m'
  exec sudo bash "$0" "$@"
  exit 1
fi

echo -e '\e[1mUpdating package cache...\e[0m'

apt update # ! sudo

echo -e '\e[1mInstalling greetd+tuigreet...\e[0m'

nix-shell -p cargo --command 'cargo build --release --targetdir src/tuigreet'
cp -f src/tuigreet/target/release/tuigreet /usr/local/bin/ # ! sudo
apt install greetd # ! sudo
# ? casper-md5check causes the OS to refuse to boot if it detects changes to the login process (required to change the DM to greetd)
systemctl disable casper-md5check # ! sudo
systemctl disable lightdm.service # ! sudo
if ! systemctl is-enabled greetd.service | grep -q 'enabled'; then
  systemctl enable greetd.service # ! sudo
fi
mkdir -p /etc/greetd # ! sudo
cp -f src/root/etc/greetd/conf.toml /etc/greetd # ! sudo
# ? pam_ecryptfs can sometimes cause greetd to fail to boot, so it is disabled here; Ubuntu considers ecryptfs to be deprecated anyways
find /etc/pam.d -type f -not -name '*.bak' -print0 \
  | xargs -0r grep -lZ '^[^#]*pam_ecryptfs' \
  | xargs -0r sed -i'.bak' '/^[^#]*pam_ecryptfs/s/^/# /' # ! sudo

echo -e '\e[1mDisabling startup splash screen...\e[0m'

sed -i.bak '/GRUB_CMDLINE_LINUX_DEFAULT/s/quiet\|splash//g' /etc/default/grub # ! sudo
update-grub # ! sudo

echo -e '\e[1mTODO: Installing i3wm...\e[0m'

echo -e '\e[1mTODO: Installing Nix Home Manager...\e[0m'

nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update
nix-shell '<home-manager>' -A install

echo -e '\e[1mConfiguring Cinnamon...\e[0m'

gsettings set org.cinnamon.desktop.interface icon-theme 'Mint-Y-Sand'
gsettings set org.cinnamon.desktop.interface gtk-theme 'Mint-Y-Dark-Aqua'
gsettings set org.cinnamon.desktop.interface gtk-theme-backup 'Adwaita'
gsettings set org.cinnamon.theme name 'cinnamon'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

echo -e '\e[1mTODO: Configuring i3wm...\e[0m'


