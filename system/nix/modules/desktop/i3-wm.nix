{ config, lib, pkgs, inputs, ... }: {
  environment.systemPackages = with pkgs; [
    dmenu
    gnome3.adwaita-icon-theme
  ];
  services.xserver.dpi = 220;
  services.xserver.upscaleDefaultCursor = true;
  environment.variables = {
    GDK_SCALE = "2.2";
    GDK_DPI_SCALE = "0.4";
    _JAVA_OPTIONS = "-Dsun.java2d.uiScale=2.2";
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    XCURSOR_SIZE = "64";
  };
  services.xserver = {
    enable = true;
    layout = "us";
    displayManager = {
      # lightdm = {
      #   enable = true;
      #   greeters.gtk = {
      #     theme.name = "Nordic-darker";
      #     iconTheme.name = "Nordzy-cyan-dark";
      #     cursorTheme.name = "Nordzy-cursors";
      #     extraConfig = ''
      #       user-background = false
      #     '';
      #   };
      # };
      defaultSession = "none+i3";
    };
    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        i3status
      ];
    };
    desktopManager = {
      xterm.enable = false;
    };
  };
}

