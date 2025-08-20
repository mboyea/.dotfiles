---
title: Linux Mint Dotfiles
author: [ Matthew T. C. Boyea ]
lang: en
keywords: [ dotfiles, linux, mint, os, ly, i3, i3wm, operating system, bash, nix ]
default_: report
---
## My personal configuration for [Linux Mint] with [Ly] and [i3wm], managed using [Bash] and [Nix Home Manager]

### Installation

- [Install Linux Mint](https://linuxmint.com/download.php), the operating system
- [Install Nix](https://nixos.org/download/), the package manager using:

  ```sh
  sh <(curl proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) --daemon
  ```
- [Install Nix Home Manager](https://nix-community.github.io/home-manager/index.xhtml#sec-install-standalone), the user package manager using:

  ```sh
  nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
  nix-channel --update
  nix-shell '<home-manager>' -A install
  ```
- Clone this git repository using:

  ```sh
  nix-shell -p git --command 'git clone https://github.com/mboyea/.dotfiles ~/.dotfiles'
  ```

[Linux Mint]: https://linuxmint.com
[Ly]: https://github.com/fairyglade/ly
[i3wm]: https://i3wm.org/
[Bash]: https://www.gnu.org/software/bash/
[Nix Home Manager]: https://github.com/nix-community/home-manager

