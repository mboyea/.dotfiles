#!/usr/bin/env bash

function echo_bold {
  options=()
  while (( "$#" )); do
    case "$1" in
      --*)
        options+=("$1")
        if [[ "${2:0:1}" != '-' ]]; then
          options+=("$2")
          shift
        fi
        shift
        ;;
      -*) options+=("$1"); shift ;;
      *) break ;;
    esac
  done
  options+=("-e")
  echo "${options[@]}" "\e[1m$@\e[0m"
}

function get_yes_confirmation {
  echo -n "$@ ("
  echo_bold -n 'y'
  echo -n '/yes to confirm) '
  read input
  if [[ "$input" =~ ^[Yy] ]]; then
    return 0
  else
    return 1
  fi
}

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

function install_system {
  if [[ $EUID -ne 0 ]]; then
    echo_bold 'System installations require root privileges.'
    exec sudo bash "$0" "$@" --system
    exit 1
  fi

  if ! $(printenv PATH | grep -q 'nix'); then
    echo_bold 'Making Nix packages accessible as root...'
    echo 'Defaults secure_path = "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin:/nix/var/nix/profiles/default/bin"' > /etc/sudoers.d/enablerootnixpkgs # ! sudo
    exec sudo bash "$0" "$@" --system
    exit 1
  fi

  echo_bold 'Updating package cache...'

  apt update # ! sudo

  echo_bold 'Installing i3wm...'
  
  apt install i3 # ! sudo
  
  echo_bold 'Installing greetd+tuigreet...'
  
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
  mkdir -p /etc/systemd/system/greetd.service.d
  cp -f "$SCRIPT_DIR/root/etc/systemd/system/greetd.service.d/override.conf" /etc/systemd/system/greetd.service.d # ! sudo
  # ? pam_ecryptfs can sometimes cause greetd to fail to boot, so it is disabled here; Ubuntu considers ecryptfs to be deprecated anyways
  find /etc/pam.d -type f -not -name '*.bak' -print0 \
    | xargs -0r grep -lZ '^[^#]*pam_ecryptfs' \
    | xargs -0r sed -i.bak '/^[^#]*pam_ecryptfs/s/^/# /' # ! sudo
  # ? hide special session configurations
  mkdir -p /usr/share/backup # ! sudo
  cp -r /usr/share/xsessions /usr/share/wayland-sessions /usr/share/backup # ! sudo
  rm -f /usr/share/xsessions/cinnamon2d.desktop # ! sudo
  rm -f /usr/share/xsessions/i3-with-shmlog.desktop # ! sudo
  rm -f /usr/share/wayland-sessions/cinnamon-wayland.desktop # ! sudo
  sed -i '/^Exec=[^>]*$/s/$/ > \/dev\/null 2>&1/' /usr/share/xsessions/i3.desktop # ! sudo
  sed -i '/^Exec=[^>]*$/s/$/ > \/dev\/null 2>&1/' /usr/share/xsessions/cinnamon.desktop # ! sudo
  
  echo_bold 'Enabling boot log screen...'
  
  sed -i.bak '/GRUB_CMDLINE_LINUX_DEFAULT/s/quiet\|splash//g' /etc/default/grub # ! sudo
  update-grub # ! sudo

  echo_bold 'Configuring system...'

  mkdir -p /etc/lightdm
  cp -f "$SCRIPT_DIR/root/etc/lightdm/slick-greeter.conf" /etc/lightdm # ! sudo

  echo_bold 'Completed system setup.'

  exec sudo -u $SUDO_USER bash "$0" "$@" --skip-system
}

function install_user {
  echo_bold 'Configuring Cinnamon...'
  
  gsettings set org.cinnamon.desktop.interface icon-theme 'Mint-Y-Sand'
  gsettings set org.cinnamon.desktop.interface gtk-theme 'Mint-Y-Dark-Aqua'
  gsettings set org.cinnamon.desktop.interface gtk-theme-backup 'Adwaita'
  gsettings set org.cinnamon.theme name 'cinnamon'
  gsettings set org.cinnamon.desktop.interface gtk-overlay-scrollbars false
  gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
  gsettings set org.x.apps.portal color-scheme 'prefer-dark'
  gsettings set org.gnome.desktop.interface cursor-theme 'Yaru'
  gsettings set org.cinnamon.desktop.interface cursor-theme 'Yaru'
  update-alternatives --set x-cursor-theme '/usr/share/icons/Adwaita/cursor.theme'
  
  echo_bold 'Installing Nix Home Manager...'
  
  nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
  nix-channel --update
  nix-shell '<home-manager>' -A install

  echo_bold 'Linking dotfiles...'

  find "$SCRIPT_DIR/home" -type f -print0 | while IFS= read -r -d '' file; do
    file_relative_path="${file#$SCRIPT_DIR/home/}"
    mkdir -p "$(dirname ~/"$file_relative_path")"
    rm -rf ~/"$file_relative_path"
    ln -s "$file" ~/"$file_relative_path"
    if [[ $? -eq 0 ]]; then
      echo "Linked $file_relative_path."
    fi
  done

  echo_bold 'Injecting Nix Home Manager configuration...'

  if ! grep -q '^\s*./common.nix' ~/.config/home-manager/home.nix; then
    if grep -q -e '^\s*imports=' -e '^\s*imports .*=' ~/.config/home-manager/home.nix; then
      sed -iE '/^\s*imports\(=\| .*=\).*/a\    ./common.nix' ~/.config/home-manager/home.nix
    else
      sed -i '/^{\S*$/a\  imports = [\n    ./common.nix\n  ];' ~/.config/home-manager/home.nix
    fi
  fi
  
  echo_bold 'Updating Nix Home Manager...'

  home-manager switch
  
  echo_bold 'Completed user setup.'
}

function main {
  args=()
  while (( "$#" )); do
    case "$1" in
      --system) DO_AUTHORIZE_SYSTEM_INSTALL=1 ;;
      --skip-system) DO_SKIP_SYSTEM_INSTALL=1 ;;
      *) echo "Error: Argument '$1' not recognized." >&2; exit 1 ;;
    esac
    args+=($1)
    shift
  done
  set -- "${args[@]}" "$@"

  if [[ -z "${DO_SKIP_SYSTEM_INSTALL:x}" ]]; then
    if [[ -n "${DO_AUTHORIZE_SYSTEM_INSTALL:x}" ]]; then
      install_system
    else
      get_yes_confirmation 'Do you want to install greetd+tuigreet and i3wm?'
      if [[ $? -eq 0 ]]; then
        install_system
      fi
    fi
  fi

  install_user
}

main "$@"

