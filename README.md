---
title: My Linux Mint Dotfiles
author: [ Matthew T. C. Boyea ]
lang: en
keywords: [ dotfiles, linux, mint, os, operating system, greetd, tuigreet, cinnamon, i3, i3wm, nix, nix home manager ]
default_: report
---
## A Linux Mint configuration with a retro-terminal aesthetic

My favorite way to do focused work is on Linux using keybinds to jump around terminals in a tiling window manager where I barely touch my mouse.
However, those are very custom setups and sometimes I need my laptop to *just work* like a normal computer...

- I **don't** want to spend time *manually setting up drivers*
- I **don't** want inturrupted by *updates breaking the computer*
- I **don't** want to deal with *niche software incompatibilities*

[Linux Mint] is an excellent mainstream linux distribution, with good defaults and solid driver support.
These are my dotfiles to setup Linux Mint like a barebones CLI-focused linux installation, while preserving the default environment.

- This replaces LightDM with [tuigreet] and shows logs at boot time for a retro-terminal aesthetic.
- This installs [i3wm] and configures [Cinnamon] for tiling.
- This uses [Nix Home Manager] for installing user packages to avoid software incompatibilities.

### Installation

1. [Install Linux Mint Cinnamon](https://linuxmint.com/download.php) the operating system

   Do *not* elect to encrypt the user drive during installation; `ecryptfs` is considered deprecated software by Ubuntu and is disabled as part of this configuration due to incompatibility.

2. [Install Nix](https://nixos.org/download/) the package installer using:

   ```sh
   sh <(curl proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) --daemon
   ```

   Then, restart your terminal to ensure Nix is included in `$PATH`

3. Clone this git repository using:

   ```sh
   nix-shell -p git --command 'git clone --recurse-submodules https://github.com/mboyea/.dotfiles ~/.dotfiles'
   ```

4. Run the install script using:

   ```sh
   ~/.dotfiles/install.sh
   ```

### FAQ

#### The text is too small on my boot / greet screen. How can I make it bigger?

Use the following command, and follow the prompts:

```sh
sudo dpkg-reconfigure console-setup
```

[Linux Mint]: https://linuxmint.com
[tuigreet]: https://github.com/apognu/tuigreet
[Cinnamon]: https://github.com/linuxmint/cinnamon
[i3wm]: https://i3wm.org/
[Nix Home Manager]: https://github.com/nix-community/home-manager
