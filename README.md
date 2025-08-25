---
title: Linux Mint Dotfiles
author: [ Matthew T. C. Boyea ]
lang: en
keywords: [ dotfiles, linux, mint, os, ly, i3, i3wm, operating system, bash, nix ]
default_: report
---
## My PC configuration for [Linux Mint Cinnamon] with [Ly] and [i3wm], controlled with [Nix Home Manager]

### Installation

1. [Install Linux Mint Cinnamon](https://linuxmint.com/download.php), the operating system
2. [Install Nix](https://nixos.org/download/), the package installer using:

   ```sh
   sh <(curl proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) --daemon
   ```

   Then, restart your terminal to ensure Nix is included in `$PATH`.

3. [Install Nix Home Manager](https://nix-community.github.io/home-manager/index.xhtml#sec-install-standalone), the package manager using:

   ```sh
   nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
   nix-channel --update
   nix-shell '<home-manager>' -A install
   ```

4. Clone this git repository using:

   ```sh
   nix-shell -p git --command 'git clone https://github.com/mboyea/.dotfiles ~/.dotfiles'
   ```

5. Run the install script using:

   ```sh
   ~/.dotfiles/install.sh
   ```

[Linux Mint]: https://linuxmint.com
[Ly]: https://github.com/fairyglade/ly
[i3wm]: https://i3wm.org/
[Nix Home Manager]: https://github.com/nix-community/home-manager

