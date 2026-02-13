{ config, pkgs, username, ... }:

{
  imports = [
    ./modules/git
    ./modules/opencode
    ./modules/ssh
    ./modules/shell
    ./modules/nvf
  ];

  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    ripgrep
    fd
    vivaldi
    yazi
  ];

  home.sessionVariables = {
    EDITOR = "vim";
  };
}
