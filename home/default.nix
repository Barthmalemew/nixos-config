{ config, pkgs, username, ... }:

{
  imports = [
    ./modules/git
    ./modules/niri
    ./modules/opencode
    ./modules/ssh
    ./modules/nvf
    ./modules/quickshell
  ];

  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    brightnessctl
    ripgrep
    fd
    vivaldi
    yazi
    foot
    kdePackages.dolphin
    grim
    slurp
    playerctl
    quickshell
  ];

  home.pointerCursor = {
    name = "Adwaita";
    package = pkgs.adwaita-icon-theme;
    size = 16;
    gtk.enable = true;
  };

  home.sessionVariables = {
    EDITOR = "vim";
    XCURSOR_SIZE = "16";
    XCURSOR_THEME = "Adwaita";
  };
}
