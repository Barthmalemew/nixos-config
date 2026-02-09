{ osConfig, lib, pkgs, ... }:

let
  themeHelper = import ./theme-helper.nix { inherit lib osConfig; };
  theme = themeHelper.colors;
in

{
  # ---------------------------------------------------------------------------
  # UNIFIED GTK / QT THEMING
  # ---------------------------------------------------------------------------
  # This module ensures that standard GUI apps (GTK and Qt) match your
  # Evangelion Unit-02 palette.

  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    gtk3.extraCss = ''
      @define-color accent_color ${theme.red};
      @define-color accent_bg_color ${theme.red};
      @define-color selected_bg_color ${theme.red};
      @define-color selected_fg_color ${theme.foreground};
    '';
    gtk4.extraCss = ''
      @define-color accent_color ${theme.red};
      @define-color accent_bg_color ${theme.red};
    '';
  };

  qt = {
    enable = true;
    platformTheme.name = "adwaita";
    style.name = "adwaita-dark";
  };
}
