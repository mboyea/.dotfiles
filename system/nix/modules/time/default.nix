{ config, lib, pkgs, inputs, ... }: {
  time.timeZone = lib.mkForce "America/Chicago";
  services.localtimed.enable = true;

  # services.automatic-timezoned.enable = lib.mkForce true;
  # services.geoclue2.enableDemoAgent = lib.mkForce true;
  # location.provider = "geoclue2";

  # services.tzupdate.enable = true;
}

