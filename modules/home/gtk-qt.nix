{ osConfig, pkgs, ... }:

let
  theme = osConfig.theme.colors;
in
{
  # ---------------------------------------------------------------------------
  # UNIFIED GTK / QT THEMING
  # ---------------------------------------------------------------------------
  # This module ensures that standard GUI apps (GTK and Qt) match your
  # Evangelion Unit-02 palette.

  # 1. GTK Configuration (Gnome/Flatpak/GTK Apps)
  gtk = {
    enable = true;
    
    # We use a standard dark theme as a base
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };

    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };

    # Inject your Red accent color into all GTK apps via CSS
    # This is the "secret sauce" that makes apps feel like they belong to your system.
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

  # 2. Qt Configuration (KDE/Qt Apps)
  qt = {
    enable = true;
    platformTheme.name = "adwaita";
    style.name = "adwaita-dark";
  };

}
