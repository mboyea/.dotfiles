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
    direnv
    (config.lib.nixGL.wrap alacritty) 
    (config.lib.nixGL.wrap discord) 
    (config.lib.nixGL.wrap spotify) 
    (config.lib.nixGL.wrap vlc)
    (config.lib.nixGL.wrap libreoffice)
    (config.lib.nixGL.wrap gimp)
    (config.lib.nixGL.wrap inkscape)
    (config.lib.nixGL.wrap audacity)
    (config.lib.nixGL.wrap lmms)
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

