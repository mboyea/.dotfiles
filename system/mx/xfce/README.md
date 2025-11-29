---
title: Linux Dotfiles
author: [ Matthew T. C. Boyea ]
lang: en
keywords: [ dotfiles, config, configuration, linux, mint, os, operating system, xfce, de, desktop environment, i3, i3wm, nix, nix home manager ]
default_: report
---
## Linux configurations by Matthew Boyea

Linux provides my favorite PC working environments.
I like to use Vim keybinds to jump between terminals, browser pages, and other workspaces.
However, I also need my laptop to *just work* for the average user.

- I **don't** want my friends to be *intimidated by the UI*
- I **don't** want to spend time *manually setting up drivers*
- I **don't** want inturrupted by *updates breaking the computer*

The system should be intuitive and attractive for users coming from Windows or Mac.
First, I expect functional screen capture, bluetooth audio support, and mouse controls to work out-of-the box.
Second, I expect the freedom to load my own window manager, login manager, and other tools with no hassle.

My current system is Linux Mint Xfce with Nix Home Manager.
Configuration for other (often incomplete) systems are backed up in the `system/` directory.

> ! I cannot garuntee the stability of my systems on your hardware, so use it your own risk !

### Usage

#### Installation

1. [Install Linux Mint](https://linuxmint.com/download.php) the operating system.

   - Configure disk
   - Enable hibernation support
   - *Do NOT enable autologin* (I have not tested it with this config)
   - Configure clock
   - Configure default user account

2. [Install Nix](https://nixos.org/download/) the package installer using:

   ```sh
   sh <(curl proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) --daemon
   ```
   ```sh
   grep -qF 'nix-daemon' /etc/rc.local || sed -i 's/^\(\s*\)\(exit\)/\1\/nix\/var\/nix\/profiles\/default\/bin\/nix-daemon\1\2/' /etc/rc.local
   ```

   Then, restart your terminal to ensure Nix is included in `$PATH`.

3. Clone this git repository using:

   ```sh
   nix-shell -p git --command 'git clone --recurse-submodules https://github.com/mboyea/.dotfiles ~/.dotfiles'
   ```

4. Run the install script using:

   ```sh
   ~/.dotfiles/install.sh
   ```

#### Updates


```sh
~/.dotfiles/install.sh
```

```sh
home-manager switch
```

### FAQ

#### Is this safe?

It is *never* safe to run code from a niche, unvetted source.
If you want to install someone's configuration, I encourage you to read through and recreate their code yourself so you know exactly how it works.

#### The text is too small on my boot / greet screen. How can I make it bigger?

Uncomment the line with `GRUB_GFXMODE=` in `/etc/default/grub`.
Apply the changes using:

```sh
sudo update-grub2
```

Then use the following command, and follow the prompts to change the display size:

```sh
sudo dpkg-reconfigure console-setup
```

#### Everything is tiny in the desktop environment. How can I make it bigger?

You're probably on a high-resolution display.

- Go to the `Display` app and set `Scale > Custom` to `0.5`.

#### How do I contribute?

Unfortunately, this project doesn't support community contributions right now.
Feel free to fork, but be sure to read the license.

