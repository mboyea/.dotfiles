#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

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

function get_confirmation {
  echo -n "$@ "
  echo_bold -n '(y/N)'
  echo -n ': '
  read response
  case "$response" in
    [yY]|[yY][eE][sS])
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

function install_system {
  if [[ $EUID -ne 0 ]]; then
    echo_bold 'System installations require root privileges.'
    exec sudo --preserve-env=PATH bash "$0" "$@" --system
    exit 1
  fi

  if ! $(printenv PATH | grep -q 'nix'); then
    echo_bold 'Making Nix packages accessible as root...'
    echo 'Defaults secure_path = "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin:/nix/var/nix/profiles/default/bin"' > /etc/sudoers.d/enablerootnixpkgs # ! sudo
    exec sudo --preserve-env=PATH bash "$0" "$@" --system
    exit 1
  fi

  echo_bold 'Updating package cache...'

  apt update

  echo_bold 'Overwriting system config files...'

  find "$SCRIPT_DIR/root" -type f -print0 | while IFS= read -r -d '' file; do
    file_relative_path="${file#$SCRIPT_DIR/root/}"
    mkdir -p "$(dirname /"$file_relative_path")"
    rm -rf /"$file_relative_path"
    cp -f "$file" /"$file_relative_path"
    if [[ $? -eq 0 ]]; then
      echo "Copied $file_relative_path."
    fi
  done

  echo_bold 'Installing greetd+tuigreet...'

  apt install -y greetd
  nix-shell -p cargo --command "cargo build --release --manifest-path '$SCRIPT_DIR/tuigreet/Cargo.toml'"
  cp -f "$SCRIPT_DIR/tuigreet/target/release/tuigreet" /usr/local/bin/
  # ? casper-md5check causes the OS to refuse to boot if it detects changes to the login process
  systemctl disable casper-md5check
  # # ? disable lightdm, then make sure greetd is enabled
  # # TODO
  # if ! systemctl is-enabled greetd.service | grep -q 'enabled'; then
  #   systemctl disable lightdm.service # ! sudo
  #   systemctl enable greetd.service # ! sudo
  # fi
  # # ? create cache directory for --remember* tuigreet features to work
  # mkdir -p /var/cache/tuigreet
  # chown _greetd:_greetd /var/cache/tuigreet
  # chmod 0755 /var/cache/tuigreet
  # ? pam_ecryptfs can sometimes cause greetd to fail to boot, so it is disabled here; Ubuntu considers ecryptfs to be deprecated anyways
  find /etc/pam.d -type f -not -name '*.bak' -print0 \
    | xargs -0r grep -lZ '^[^#]*pam_ecryptfs' \
    | xargs -0r sed -i.bak '/^[^#]*pam_ecryptfs/s/^/# /' # ! sudo
  # # ? hide special session configurations
  # mkdir -p /usr/share/backup
  # cp -rf /usr/share/xsessions /usr/share/wayland-sessions /usr/share/backup
  # rm -f /usr/share/xsessions/i3-with-shmlog.desktop
  # rm -f /usr/share/xsessions/i3.desktop
  # ? hide xorg output on session startup
  sed -i '/^Exec=[^>]*$/s/$/ > \/dev\/null 2>&1/' /usr/share/xsessions/xfce.desktop
  # ! sed -i '/^Exec=[^>]*$/s/$/ > \/dev\/null 2>&1/' /usr/share/xsessions/i3.desktop

  # echo_bold 'Installing i3wm...'
  # TODO
  
  echo_bold 'Enabling visible boot logs...'
  
  sed -i.bak '/GRUB_CMDLINE_LINUX_DEFAULT/s/quiet\|splash//g' /etc/default/grub
  update-grub
  # 
  # apt install -y i3

  echo_bold 'Completed system setup.'

  exec sudo --preserve-env=PATH -u $SUDO_USER bash "$0" "$@" --skip-system
}

function install_user {
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

  if ! command -v home-manager &> /dev/null; then
    echo_bold 'Installing Nix Home Manager...'
    nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
    nix-channel --update
    nix-shell '<home-manager>' -A install
  fi


  if ! grep -q '^\s*./common.nix' ~/.config/home-manager/home.nix; then
    echo_bold 'Injecting Nix Home Manager configuration...'
    if grep -q -e '^\s*imports=' -e '^\s*imports .*=' ~/.config/home-manager/home.nix; then
      sed -iE '/^\s*imports\(=\| .*=\).*/a\    ./common.nix' ~/.config/home-manager/home.nix
    else
      sed -i '/^{\S*$/a\  imports = [\n    ./common.nix\n  ];' ~/.config/home-manager/home.nix
    fi
  fi
  
  echo_bold 'Updating Nix Home Manager...'

  home-manager switch

  # echo_bold 'Configuring Settings...'
  # # TODO
  # # ! gsettings set org.cinnamon.desktop.interface icon-theme 'Mint-Y-Sand'
  # # ! gsettings set org.cinnamon.desktop.interface gtk-theme 'Mint-Y-Dark-Aqua'
  # # ! gsettings set org.cinnamon.desktop.interface gtk-theme-backup 'Adwaita'
  # # ! gsettings set org.cinnamon.theme name 'cinnamon'
  # # ! gsettings set org.cinnamon.desktop.interface gtk-overlay-scrollbars false
  # # ? set xfce options
  # gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
  # gsettings set org.x.apps.portal color-scheme 'prefer-dark'
  # gsettings set org.gnome.desktop.interface cursor-theme 'Yaru'
  # gsettings set org.cinnamon.desktop.interface cursor-theme 'Yaru'
  # update-alternatives --set x-cursor-theme '/usr/share/icons/Adwaita/cursor.theme'

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
      if get_confirmation 'Run system install for Linux Mint XFCE (greetd+tuigreet+i3wm)?'; then
        install_system
      fi
    fi
  fi

  install_user
}

main "$@"

