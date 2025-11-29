# For help editing Nix config files, use any of the following
#  man configuration.nix
#  nixos-help
#  https://search.nixos.org/options
#  https://mynixos.com/search

{ config, lib, pkgs, inputs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ./modules
    ./users
  ];

  networking.hostName = "barenix";

  environment = {
    systemPackages = with pkgs; [
      git
      gh
      home-manager
      neovim
    ];
    variables = {
      EDITOR = "nvim";
    };
  };

  # This option declares the oldest NixOS version installed on this machine
  #
  # It is used to maintain compatibility when new versions are installed
  #
  # Most users should NEVER change this value
  #
  # This value does NOT affect the version of Nix packages you install
  #
  # This value being lower than the current NixOS release does NOT mean
  # your system is out of date, out of support, or vulnerable
  #
  # For more information, see `man configuration.nix` or
  # https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion
  system.stateVersion = "24.05";
}
