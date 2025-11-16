#!/usr/bin/env bash

### UTILS ###

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

function echo_error { cat <<< "Error: $@" >&2; }

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

### SCRIPT ###

function install_user {
  echo_bold 'Linking dotfiles...'
  find "$SCRIPT_DIR/home" -type f -print0 | while IFS= read -r -d '' file; do
    file_relative_path="${file#$SCRIPT_DIR/home/}"
    mkdir -p "$(dirname ~/"$file_relative_path")"
    rm -rf ~/"$file_relative_path"
    ln -s "$file" ~/"$file_relative_path"
    if [[ $? -eq 0 ]]; then
      echo "Linked $file_relative_path"
    fi
  done

  if ! command -v home-manager &> /dev/null; then
    echo_bold 'Installing Nix Home Manager...'
    nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
    nix-channel --update
    nix-shell '<home-manager>' -A install
    grep -q 'hm-session-vars.sh' ~/.bashrc || echo -e '. "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"\n' >> ~/.bashrc
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
  
#   # ? TODO: set xfce options
#   # echo_bold 'Configuring additonal desktop settings...'
#   # gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
#   # gsettings set org.x.apps.portal color-scheme 'prefer-dark'
#   # gsettings set org.gnome.desktop.interface cursor-theme 'Yaru'
#   # gsettings set org.cinnamon.desktop.interface cursor-theme 'Yaru'
#   # update-alternatives --set x-cursor-theme '/usr/share/icons/Adwaita/cursor.theme'

  echo_bold 'Completed user setup.'
}

function install_system {
  if [[ $EUID -ne 0 ]]; then
    echo_bold 'System installations require root privileges.'
    exec sudo --preserve-env=PATH bash "$0" -s "$OPTS" -- "$ARGS"
    exit 1
  fi

  if ! $(printenv PATH | grep -q 'nix'); then
    echo_bold 'Making Nix packages accessible as root...'
    echo 'Defaults secure_path = "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/nix/var/nix/profiles/default/bin"' > /etc/sudoers.d/enablerootnixpkgs # ! sudo
    exec sudo --preserve-env=PATH bash "$0" -s "$OPTS" -- "$ARGS"
    exit 1
  fi

  echo_bold 'Updating package cache...'
  apt update

  echo_bold 'Overwriting system config files...'
  find "$SCRIPT_DIR/system/mx/xfce/root" -type f -print0 | while IFS= read -r -d '' file; do
    file_relative_path="${file#$SCRIPT_DIR/system/mx/xfce/root/}"
    mkdir -p "$(dirname /"$file_relative_path")"
    rm -rf /"$file_relative_path"
    cp -f "$file" /"$file_relative_path"
    if [[ $? -eq 0 ]]; then
      echo "Copied $file_relative_path"
    fi
  done

  if ! command -v greetd &> /dev/null; then
    echo_bold 'Installing greetd...'
    apt install -y greetd
  fi

  echo_bold 'Installing tuigreet...'
  nix-shell -p cargo --command "cargo build --release --manifest-path '$SCRIPT_DIR/software/tuigreet/Cargo.toml'"
  cp -f "$SCRIPT_DIR/software/tuigreet/target/release/tuigreet" /usr/local/bin/
  # ? create cache directory for --remember* tuigreet features to work
  mkdir -p /var/cache/tuigreet
  chown _greetd:_greetd /var/cache/tuigreet
  chmod 0755 /var/cache/tuigreet

  DISPLAY_MANAGER=$(basename $(cat /etc/X11/default-display-manager))
  if [[ "$DISPLAY_MANAGER" != 'greetd' ]]; then
    # echo_bold 'Enabling greetd...'
    # echo '/usr/sbin/greetd' > /etc/X11/default-display-manager
    # rm -rf /etc/systemd/system/display-manager.service
    # dpkg-reconfigure -f noninteractive greetd
  fi

  # echo_bold 'Configuring startup behavior...'
#   # ? hide xorg output on session startup
#   sed -i '/^Exec=[^>]*$/s/$/ > \/dev\/null 2>&1/' /usr/share/xsessions/xfce.desktop
#   # ! sed -i '/^Exec=[^>]*$/s/$/ > \/dev\/null 2>&1/' /usr/share/xsessions/i3.desktop

#   echo_bold 'Enabling visible boot logs...'
#   sed -i.bak '/GRUB_CMDLINE_LINUX_DEFAULT/s/quiet\|splash//g' /etc/default/grub
#   update-grub

#   # echo_bold 'Installing i3wm...'
#   # apt install -y i3
#   # # ? hide other session configurations
#   # mkdir -p /usr/share/backup
#   # cp -rf /usr/share/xsessions /usr/share/wayland-sessions /usr/share/backup
#   # rm -f /usr/share/xsessions/i3-with-shmlog.desktop
#   # rm -f /usr/share/xsessions/i3.desktop

  echo_bold 'Completed system setup.'
  exec sudo --preserve-env=PATH -u $SUDO_USER bash "$0" "$OPTS" -S 'false' -- "$ARGS"
}

function interpret_opts_args {
  OPTS=$(getopt -o nsS:uU: -l system:,user: -- "$@")
  if [ $? != 0 ]; then
    exit 1
  fi
  eval set -- "$OPTS"
  while true; do
    case "$1" in
      --) shift; break ;;
      -n) ;;
      -s) DO_SYSTEM="true"; shift ;;
      -u) DO_USER="true"; shift ;;
      -S|--system) DO_SYSTEM="$2"; shift 2 ;;
      -U|--user) DO_USER="$2"; shift 2 ;;
      *) echo_error "Execution outside of expected bounds in function interpret_args" ; exit 1 ;;
    esac
  done
  ARGS="$@"
}

function main {
  interpret_opts_args "$@"

  if [[ "$DO_SYSTEM" != 'false' ]]; then
    if [[ -n "${DO_SYSTEM:x}" ]] || get_yes_confirmation 'Install system config?'; then
      install_system
    fi
  fi
  if [[ "$DO_USER" != 'false' ]]; then
    install_user
  fi
}

main "$@"

