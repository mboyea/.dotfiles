{ config, lib, pkgs, inputs, ... }: {
  nixGL.packages = import <nixgl> { inherit pkgs; };

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
    (config.lib.nixGL.wrap alacritty) 
    (config.lib.nixGL.wrap discord) 
    spotify
    vlc
    libreoffice
    gimp
    inkscape
    audacity
    lmms
    (config.lib.nixGL.wrap obs-studio)
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    BROWSER = "firefox"; # ? provided by apt with Linux Mint Cinnamon
    TERMINAL = "alacritty";
  };
}

