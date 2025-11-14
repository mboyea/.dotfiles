# Matthew Boyea's NixOS Config

## A NixOS configuration using Disko, Impermanence, & Nix Home Manager

These configuration files are to be used during the installation of [NixOS] to create my preferred Linux PC in a declarative manner.

* [Disko] is used to partition drives declaratively.
* [Impermanence] is used to wipe most of the filesystem on every boot, reverting non-declarative changes to the system.
* A user-level [Nix Home Manager] installation enables users to install programs and modify user preferences without root-level permissions.

The operating system is setup to be installed on a single storage device in a computer. This storage device is ideally a Solid State Drive (SSD) or a Hard Disk Drive (HDD), and will have a specific `<disk_name>`.

Each computer that uses operating system this is called a `host`. Every host should have a unique `<host_name>`.

Each person that uses this operating system is called a `user`. Every user should have a unique `<user_name>`.

### Fork Files

* [Fork this repository](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/working-with-forks/fork-a-repo#forking-a-repository) so that you can keep a copy of your own files on GitHub.
  Then when I make updates later, you could easily merge them into your own changes.

### Manually Install Operating System

First, a few notes for newbies to the Linux Console.

* You can type `man` before a command name to learn what it does.
  For example, `man ls` tells you all options for how to list a directory.
* To copy and paste in the console, you must use `Ctrl+Shift+C` and `Ctrl+Shift+V` respectively.
  This is because `Ctrl+C` cancels a program and `Ctrl+V` literally inserts the next character typed.
* You may temporarily install a preferred text editor to use instead of `nano`.
  I get `nvim` using `nix-shell -p neovim`.
  Search for your favorites at [search.nixos.org](https://search.nixos.org/packages).

For a video to help you understand the installation process, see [Perfect NixOS | Impermanence Setup](https://www.youtube.com/watch?v=YPKwkWtK7l0) by Vimjoyer.
My thanks go out to him for helping me to learn NixOS.
Note that this process is different from his, so follow these instructions word for word after watching the video.

#### Prepare The Installer

* [Download a graphical NixOS installer](https://nixos.org/download/).
  Graphical NixOS installers have easier methods to connect to wireless internet networks.
* [Prepare the NixOS installer onto a flash drive](https://nixos.wiki/wiki/NixOS_Installation_Guide#Making_the_installation_media).
* [Boot the NixOS installer from the flash drive](https://nixos.wiki/wiki/NixOS_Installation_Guide#Booting_the_installation_media).
  Close the visual installer; we'll do everything in the Console.
* [Connect to the internet](https://nixos.org/manual/nixos/stable/#sec-installation-manual-networking).
  I use `nmtui`.

#### Partition The Drives

Reproducibility is ideal, so we use [Disko] to declare our drive partitions instead of creating them manually.

* Download a Disko configuration file using:

  ```sh
  curl https://raw.githubusercontent.com/mboyea/nixos-config/main/hosts/barenix/disko.nix -o /tmp/disko.nix
  ```

  **Note:** to paste into a terminal, use `Ctrl+Shift+V`.
* Modify the Disko file as you see fit using `nano /tmp/disko.nix`.
  Note that the `swap` partition should be at least 1.5x the amount of RAM you have installed (check using `free -g -h -t`) if you want the PC to support hibernation.
* Find the `<disk_name>` you want to install NixOS onto using `lsblk`.
  You're looking for something like `vda`, `sda`, `nvme0`, or `nvme0n1`.
* Partition your disk using:

  ```sh
  sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko /tmp/disko.nix --arg device '"/dev/<disk_name>"'
  ```

#### Install NixOS

* Run `nix-shell -p git` to install git temporarily.
  You may also want to install your preferred text editor at this time.
* Copy this repository (`<github_url>`) to `/mnt/etc/nixos` using:

  ```sh
  sudo mkdir -p /mnt/etc
  sudo git clone <github_url> /mnt/etc/nixos
  sudo rm -rf /mnt/etc/nixos/.git
  ```

* Generate NixOS configuration files using:

  ```sh
  sudo nixos-generate-config --no-filesystems --root /mnt
  sudo rm -rf /mnt/etc/nixos/configuration.nix
  sudo mv /tmp/disko.nix /mnt/etc/nixos
  sudo cp -t /mnt/etc/nixos /mnt/etc/nixos/hosts/barenix/configuration.nix /mnt/etc/nixos/hosts/barenix/flake.nix
  ```

* Modify the flake file to specify your `<disk_name>` using `sudo nano /mnt/etc/nixos/flake.nix`:

  ```nix
  {
    <...>
    outputs = { nixpkgs, ... } @ inputs:
    let
      <...>
      diskName = "<disk_name>";           # modify this
    in {
      <...>
    };
  }
  ```

* Copy your configuration files to `/persist` using:

  ```sh
  sudo mkdir -p /mnt/persist/system/etc
  sudo cp -r /mnt/etc/nixos /mnt/persist/system/etc
  ```

* Run `sudo nixos-install --flake /mnt/etc/nixos#barenix && reboot` and wait for the computer to boot into NixOS.
* Log in to user `admin` using password `admin`.
  It is now safe to disconnect the flash drive.

#### Configure a Host

* [Connect to the internet](https://nixos.org/manual/nixos/stable/#sec-installation-manual-networking).
  I use `nmtui`.
* Clone this repository (`<github_url>`) into `~/.config/` using:

  ```sh
  mkdir ~/.config
  git clone <github_url> ~/.config/nixos
  ```

* Copy the configuration files for this host (`<host_name>`) using:

  ```sh
  mkdir -p ~/.config/nixos/hosts/<host_name>
  cd /etc/nixos
  cp -t ~/.config/nixos/hosts/<host_name> configuration.nix hardware-configuration.nix flake.nix disko.nix
  ```

* Create symlinks to this host's config files in the base directory of your configuration using:

  ```sh
  ln -s -t ~/.config/nixos hosts/<host_name>/configuration.nix hosts/<host_name>/disko.nix hosts/<host_name>/flake.nix hosts/<host_name>/hardware-configuration.nix
  ```

* Modify the configuration file to specify your `<host_name>` and correct the imports paths using `nano ~/.config/nixos/configuration.nix`:

  ```nix
  # For help editing Nix config files, use any of the following
  #  man configuration.nix
  #  nixos-help
  #  https://search.nixos.org/options
  #  https://mynixos.com/search
  
  { config, lib, pkgs, inputs, ... }: {
    imports = [
      ./hardware-configuration.nix
      ../../modules                       # modify this
      ../../users                         # modify this
    ];
  
    networking.hostName = "<host_name>";  # modify this
  
    <...>
  }
  ```

* Modify the flake file to specify your `<host_name>` using `nano ~/.config/nixos/flake.nix`:

  ```nix
  {
    <...>
    outputs = { nixpkgs, ... } @ inputs:
    let
      <...>
      hostName = "<host_name>";           # modify this
      <...>
    in {
      <...>
    };
  }
  ```

* Symlink to the configuration in the `/etc/nixos` directory using:

  ```sh
  sudo rm -rf /etc/nixos/*
  sudo ln -s -t /etc/nixos ~/.config/nixos/flake.nix
  ```

* Stage the configuration to git. NixOS will fail to build a configuration unless the git repository is staged.
* Switch to your newly configured host (`<host_name>`) using:

  ```sh
  sudo nixos-rebuild boot --flake etc/nixos/hosts/<host_name>#<host_name> && reboot
  ```

* Log in to user `admin` using password `admin`.

### Create Users

### Modify User Preferences

In NixOS, it is widely recommended that users install applications and modify their configurations using [Nix Home Manager].

See [my preferred Nix Home Manager config](https://github.com/mboyea/home-manager) for guidance.

### Contribute

Unfortunately, this project doesn't support community contributions right now. Feel free to fork, but be sure to [read the license](./LICENSE.md).

[NixOS]: https://nixos.org/
[Disko]: https://nixos.wiki/wiki/Disko
[Impermanence]: https://github.com/nix-community/impermanence
[Nix Home Manager]: https://github.com/nix-community/home-manager
