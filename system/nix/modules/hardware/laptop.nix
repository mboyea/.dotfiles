{ config, lib, pkgs, inputs, ... }: {
  # boot.kernelParams = [ "psmouse.synaptics_intertouch=0" ];
  # hardware.enableAllFirmware = true;
  hardware.enableRedistributableFirmware = true;

  boot.supportedFilesystems = [ "ntfs" ];

  # don't suspend on lid close
  services.logind.lidSwitchExternalPower = "ignore";
  systemd.sleep.extraConfig = ''
    AllowSuspend=no
    AllowHibernation=yes
    AllowHybridSleep=no
    AllowSuspendThenHibernate=no
  '';

  # enable screen sharing
  environment.systemPackages = [ pkgs.xdg-desktop-portal-wlr ];
  xdg.portal = {
    enable = true;
    wlr.enable = true;
  };
  # if causing long startups, enable: services.dbus.enable = true;
}
