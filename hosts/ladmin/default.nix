{ config, pkgs, username, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system/common.nix
  ];

  networking.hostName = "ladmin";

  users.users.${username} = {
    isNormalUser = true;
    description = username;
    extraGroups = [ "networkmanager" "wheel" ];
  };

  home-manager.users.${username} = import ../../home;

  # GPU drivers - UNCOMMENT YOUR GPU
  # Intel:
  # services.xserver.videoDrivers = [ "intel" ];
  # hardware.graphics.extraPackages = with pkgs; [ intel-media-driver ];
  
  # AMD:
  # services.xserver.videoDrivers = [ "amdgpu" ];
  
  # NVIDIA:
  # services.xserver.videoDrivers = [ "nvidia" ];
  # hardware.nvidia.modesetting.enable = true;

  system.stateVersion = "25.11";
}
