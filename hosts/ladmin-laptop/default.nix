{ config, pkgs, username, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system/common.nix
    ../../modules/system/laptop.nix
  ];

  networking.hostName = "ladmin-laptop";

  users.users.${username} = {
    isNormalUser = true;
    description = username;
    extraGroups = [ "networkmanager" "wheel" ];
  };

  home-manager.users.${username} = import ../../home;

  # Intel Arc integrated graphics
  services.xserver.videoDrivers = [ "intel" ];
  hardware.graphics.extraPackages = with pkgs; [ 
    intel-media-driver  # For newer Intel GPUs (Arc)
    intel-vaapi-driver  # Hardware video acceleration
  ];

  system.stateVersion = "25.11";
}
