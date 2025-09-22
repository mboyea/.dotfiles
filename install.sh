#!/usr/bin/env bash

if [[ $EUID -ne 0 ]]; then
  echo -e '\e[1mThis installation script requires root privileges.\e[0m'
  exec sudo bash "$0" "$@"
  exit 1
fi

if printenv PATH | grep -vq 'nix'; then
  echo -e '\e[1mMaking Nix packages accessible as root...\e[0m'
  echo 'Defaults secure_path = "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin:/nix/var/nix/profiles/default/bin"' > /etc/sudoers.d/enablerootnixpkgs # ! sudo
  exec sudo bash "$0" "$@"
  exit 1
fi

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

echo -e '\e[1mUpdating package cache...\e[0m'

apt update # ! sudo

echo -e '\e[1mInstalling i3wm...\e[0m'

apt install i3 # ! sudo

echo -e '\e[1mInstalling greetd+tuigreet...\e[0m'

nix-shell -p cargo --command "cargo build --release --manifest-path '$SCRIPT_DIR/tuigreet/Cargo.toml'"
cp -f "$SCRIPT_DIR/tuigreet/target/release/tuigreet" /usr/local/bin/ # ! sudo
apt install greetd # ! sudo
# ? casper-md5check causes the OS to refuse to boot if it detects changes to the login process
systemctl disable casper-md5check # ! sudo
# ? disable lightdm, then make sure greetd is enabled
if ! systemctl is-enabled greetd.service | grep -q 'enabled'; then
  systemctl disable lightdm.service # ! sudo
  systemctl enable greetd.service # ! sudo
fi
# ? create cache directory for --remember* tuigreet features to work
mkdir -p /var/cache/tuigreet # ! sudo
chown _greetd:_greetd /var/cache/tuigreet # ! sudo
chmod 0755 /var/cache/tuigreet # ! sudo
# ? configure greetd to use tuigreet
mkdir -p /etc/greetd # ! sudo
cp -f "$SCRIPT_DIR/root/etc/greetd/config.toml" /etc/greetd # ! sudo
# ? pam_ecryptfs can sometimes cause greetd to fail to boot, so it is disabled here; Ubuntu considers ecryptfs to be deprecated anyways
find /etc/pam.d -type f -not -name '*.bak' -print0 \
  | xargs -0r grep -lZ '^[^#]*pam_ecryptfs' \
  | xargs -0r sed -i'.bak' '/^[^#]*pam_ecryptfs/s/^/# /' # ! sudo
# ? hide special session configurations
mkdir -p /usr/share/backup # ! sudo
cp -r /usr/share/xsessions /usr/share/wayland-sessions /usr/share/backup # ! sudo
rm -f /usr/share/xsessions/cinnamon2d.desktop # ! sudo
rm -f /usr/share/xsessions/i3-with-shmlog.desktop # ! sudo
rm -f /usr/share/wayland-sessions/cinnamon-wayland.desktop # ! sudo
sed '/^Exec=[^>]*$/s/$/ > \/dev\/null 2>&1/' /usr/share/xsessions/i3.desktop # ! sudo
sed '/^Exec=[^>]*$/s/$/ > \/dev\/null 2>&1/' /usr/share/xsessions/cinnamon.desktop # ! sudo

echo -e '\e[1mEnabling boot log screen...\e[0m'

sed -i.bak '/GRUB_CMDLINE_LINUX_DEFAULT/s/quiet\|splash//g' /etc/default/grub # ! sudo
update-grub # ! sudo

echo -e '\e[1mConfiguring Cinnamon...\e[0m'

gsettings set org.cinnamon.desktop.interface icon-theme 'Mint-Y-Sand'
gsettings set org.cinnamon.desktop.interface gtk-theme 'Mint-Y-Dark-Aqua'
gsettings set org.cinnamon.desktop.interface gtk-theme-backup 'Adwaita'
gsettings set org.cinnamon.theme name 'cinnamon'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.x.apps.portal color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface cursor-theme 'Yaru'
gsettings set org.cinnamon.desktop.interface cursor-theme 'Yaru'
x.dm.slick-greeter cursor-theme-name 'Adwaita'
update-alternatives --set x-cursor-theme '/usr/share/icons/Adwaita/cursor.theme'
gsettings set org.cinnamon.desktop.interface gtk-overlay-scrollbars false

echo -e '\e[1mCompleted system setup.\e[0m'

# todo: switch back to active user ($SUDO_USER)

# todo: install nix home manager

# todo: recursively symlink every file found in home/

# todo: inject include of common.nix into home.nix

# todo: run nix home manager switch

echo -e '\e[1mTODO:Completed user setup.\e[0m'
