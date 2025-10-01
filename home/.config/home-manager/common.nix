{ config, lib, pkgs, inputs, ... }: {
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
    alacritty
    vscode
    discord
    spotify
    vlc
    libreoffice
    gimp
    inkscape
    audacity
    lmms
    obs-studio
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    BROWSER = "firefox"; # ? provided by apt with Linux Mint Cinnamon
    TERMINAL = "alacritty";
  };
}

