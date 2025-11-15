{ config, lib, pkgs, inputs, ... }: {
  targets.genericLinux.nixGL.packages = import (builtins.fetchTarball {
    url = "https://github.com/nix-community/nixGL/archive/a8e1ce7d49a149ed70df676785b07f63288f53c5.tar.gz";
    sha256 = "sha256:010n26nhha1l64m7m08rzrfhyixfr8japn3vzbn80dj092wwggrr";
  }) { inherit pkgs; };

  nixpkgs = {
    config = {
      allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
        "vscode"
        "discord"
        "spotify"
      ];
    };
  };

  home.packages = with pkgs; [
    neovim
    git
    gh
    direnv
    (config.lib.nixGL.wrap alacritty) 
    (config.lib.nixGL.wrap discord) 
    (config.lib.nixGL.wrap spotify) 
    (config.lib.nixGL.wrap vlc)
    # (config.lib.nixGL.wrap libreoffice) # can't install due to cache miss + 5hr build
    (config.lib.nixGL.wrap gimp)
    (config.lib.nixGL.wrap inkscape)
    (config.lib.nixGL.wrap audacity)
    # (config.lib.nixGL.wrap lmms) # can't install due to cache miss + build failure
    (config.lib.nixGL.wrap obs-studio)
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    BROWSER = "firefox"; # ? provided by apt with Linux Mint
    TERMINAL = "alacritty";
  };

  nix = {
    package = pkgs.nix;
    settings.experimental-features = [ "nix-command" "flakes" ];
  };
}

