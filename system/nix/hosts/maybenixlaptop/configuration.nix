# For help editing Nix config files, use any of the following
#  man configuration.nix
#  nixos-help
#  https://search.nixos.org/options
#  https://mynixos.com/search

{ config, lib, pkgs, inputs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ../../modules
    ../../modules/desktop
    ../../modules/sound
    ../../modules/hardware/intel.nix
    ../../modules/hardware/laptop.nix
    ../../users/admin
  ];

  networking.hostName = "maybenixlaptop";
  networking.firewall.allowedTCPPorts = [
    443
    992
    5555
    25565
  ];
  networking.firewall.allowedUDPPorts = [
    500
    1194
    1701
    4500
    25565
  ];

  i18n.defaultLocale = "en_US.UTF-8";

  environment = {
    systemPackages = with pkgs; [
      git
      gh
      chromium
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
