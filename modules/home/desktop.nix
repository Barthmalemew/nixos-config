{ osConfig, lib, pkgs, ... }:

let
  themeHelper = import ./theme-helper.nix { inherit lib osConfig; };
  theme = themeHelper.colors;
in

{
  # ---------------------------------------------------------------------------
  # DESKTOP ENVIRONMENT (Visuals)
  # ---------------------------------------------------------------------------
  # This module handles the visual components of your desktop.

  # 1. QuickShell
  systemd.user.services.quickshell = {
    Unit = {
      Description = "QuickShell Desktop Shell";
      After = [ "graphical-session.target" "dbus-niri-environment.service" ];
      Wants = [ "dbus-niri-environment.service" ];
      PartOf = [ "graphical-session.target" ];
      ConditionEnvironment = "WAYLAND_DISPLAY";
    };
    Service = {
      ExecStart = "${pkgs.quickshell}/bin/qs";
      Restart = "on-failure";
      RestartSec = 2;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  # 2. Wallpaper (SwayBG)
  systemd.user.services.swaybg = {
    Unit = {
      Description = "Swaybg Wallpaper Service";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.swaybg}/bin/swaybg -m fill -i ${../../assets/wallpapers/unit2.png}";
      Restart = "always";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  # 3. Lock Screen (SwayLock)
  programs.swaylock = {
    enable = true;
    settings = {
      image = "${../../assets/wallpapers/unit2.png}";
      scaling = "fill";
      color = "${theme.background}";
      
      # Ring Colors (Matches Theme)
      inside-color = "${theme.background}99";
      ring-color = "${theme.panelBorder}";
      line-color = "${theme.background}";
      key-hl-color = "${theme.highlight}";
      separator-color = "${theme.background}";
      
      # Text Colors
      text-color = "${theme.foreground}";
      text-caps-lock-color = "${theme.red}";
      
      daemonize = true;
    };
  };
}
