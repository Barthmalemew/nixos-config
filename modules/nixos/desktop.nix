{ pkgs, ... }:

{
  # --- Desktop Environment (Niri/Wayland) ---
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  programs.niri.enable = true;
  programs.xwayland.enable = true;

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    QT_QPA_PLATFORM = "wayland;xcb";
    GDK_BACKEND = "wayland,x11";
    SDL_VIDEODRIVER = "wayland";
    CLUTTER_BACKEND = "wayland";
  };

  xdg.portal = {
    enable = true;

    # Niri is wlroots-based; use the wlroots portal for screencast/screenshot
    # (screen sharing, PipeWire). Keep KDE/GTK for file dialogs and general UI.
    extraPortals = [
      pkgs.xdg-desktop-portal-wlr
      pkgs.kdePackages.xdg-desktop-portal-kde
      pkgs.xdg-desktop-portal-gtk
    ];

    config.common = {
      default = [ "kde" "gtk" "wlr" ];
      "org.freedesktop.impl.portal.ScreenCast" = "wlr";
      "org.freedesktop.impl.portal.Screenshot" = "wlr";
    };
  };
}
