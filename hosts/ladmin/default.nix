{ username, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system/common.nix
  ];

  networking.hostName = "ladmin";

  users.users.${username} = {
    isNormalUser = true;
    description = username;
    extraGroups = [ "networkmanager" "wheel" "docker" ];
  };

  # Minimal Docker runtime support (CLI stays in project dev shells)
  virtualisation.docker.enable = true;

  # OpenRGB
  services.hardware.openrgb = {
    enable = true;
    motherboard = "amd";
  };

  # AMD RX 7800 XT
  services.xserver.videoDrivers = [ "amdgpu" ];
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  system.stateVersion = "25.11";
}
