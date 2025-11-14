{ config, lib, pkgs, inputs, ... }: {
  networking = {
    networkmanager = {
      enable = true;
      dhcp = "dhcpcd";
      # dns = "systemd-resolved"
    };
    firewall = {
      enable = true;
      allowedTCPPorts = [];
      allowedUDPPorts = [];
    };
  };

  i18n.defaultLocale = "en_US.UTF-8";

  services.printing.enable = true;

  hardware.bluetooth.enable = true;
  # hardware.bluetooth.hsphfpd.enable = true; # incompatible with pipewire.wireplumber

  # automount usb drives
  services.udisks2.enable = true;
  services.devmon.enable = true;
  services.gvfs.enable = true;

}

