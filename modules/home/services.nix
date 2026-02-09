{ config, pkgs, ... }:

let
  niriEnvScript = pkgs.writeShellScript "dbus-niri-environment" ''
    set -eu

    # xdg-desktop-portal backend selection is keyed off XDG_CURRENT_DESKTOP.
    # niri sets it to "niri", but xdg-desktop-portal-wlr advertises UseIn=wlroots.
    # Add a wlroots marker so ScreenCast/Screenshot backends get picked up.
    if [ "''${XDG_CURRENT_DESKTOP-}" != "" ]; then
      case ":''${XDG_CURRENT_DESKTOP}:" in
        *:wlroots:*) ;;
        *) export XDG_CURRENT_DESKTOP="''${XDG_CURRENT_DESKTOP}:wlroots" ;;
      esac
    else
      export XDG_CURRENT_DESKTOP="wlroots"
    fi

    # Make session environment visible to systemd user services (ConditionEnvironment)
    ${pkgs.systemd}/bin/systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE NIRI_SOCKET || true

    # Also update DBus activation environment.
    ${pkgs.dbus}/bin/dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE NIRI_SOCKET
  '';
in

{
  # ---------------------------------------------------------------------------
  # BACKGROUND SERVICES
  # ---------------------------------------------------------------------------
  # These services run in the background to handle system integration.

  # 1. Dbus Activation Environment
  systemd.user.services.dbus-niri-environment = {
    Unit = {
      Description = "Update DBus environment for Niri";
      Before = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = [ "${niriEnvScript}" ];
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  # 2. Polkit Agent
  systemd.user.services.polkit-kde-agent = {
    Unit = {
      Description = "Polkit KDE Authentication Agent";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1";
      Restart = "on-failure";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  # 3. Idle Daemon (SwayIdle)
  services.swayidle = {
    enable = true;
    timeouts = [
      { timeout = 600; command = "${pkgs.swaylock}/bin/swaylock -f"; }
      { timeout = 900; command = "${pkgs.niri}/bin/niri msg action power-off-monitors"; resumeCommand = "${pkgs.niri}/bin/niri msg action power-on-monitors"; }
    ];
    events = {
      before-sleep = "${pkgs.swaylock}/bin/swaylock -f";
      lock = "${pkgs.swaylock}/bin/swaylock -f";
    };
  };

  # 4. Clipboard Manager
  services.cliphist = {
    enable = true;
    allowImages = true;
  };

  # 5. Auto-mount Utility
  services.udiskie.enable = true;
}
