{ config, pkgs, username, ... }:

{
  imports = [
    ./modules/git
    ./modules/niri
    ./modules/waybar
    ./modules/opencode
    ./modules/ssh
    ./modules/nvf
  ];

  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    ripgrep
    fd
    firefox
    vivaldi
    yazi
    wofi
    foot
    kdePackages.dolphin
  ];

  home.sessionVariables = {
    EDITOR = "vim";
  };
}
