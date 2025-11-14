{ config, lib, pkgs, inputs, ... }: {
  environment.systemPackages = with pkgs; [
    grim               # screenshots
    slurp              # screenshots
    wl-clipboard       # copy/paste
    mako               # notifications
    alacritty          # terminal
    pamixer            # audio
    pavucontrol        # audio
    pulseaudio         # audio
    alsa-utils         # audio
    playerctl          # media players
    brightnessctl      # screen brightness
    acpi               # battery status
  ];
  services.gnome.gnome-keyring.enable = true;
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd sway";
	user = "greeter";
      };
    };
  };
  environment.etc."sway/config".text = builtins.readFile ./sway-config;
  environment.etc."gtk-3.0/settings.ini".text = builtins.readFile ./gtk-settings.ini;
  environment.persistence."/persist/system" = {
    directories = [
      "/etc/sway"
      "/etc/gtk-3.0"
    ];
  };
}

