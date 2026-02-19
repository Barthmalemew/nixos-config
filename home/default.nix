{ pkgs, username, ... }:

{
  imports = [
    ./modules/direnv
    ./modules/git
    ./modules/niri
    ./modules/opencode
    ./modules/ssh
    ./modules/nvf
    ./modules/quickshell
    ./modules/terminal
    ./modules/zsh
  ];

  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    brightnessctl
    ripgrep
    fd
    gh
    jq
    vlc
    vivaldi
    jetbrains.idea
    jetbrains.pycharm
    jetbrains.webstorm
    jetbrains.rider
    android-studio
    yazi
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
    EDITOR = "nvim";
    XCURSOR_SIZE = "16";
    XCURSOR_THEME = "Adwaita";
  };
}
