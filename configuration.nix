{ config, lib, pkgs, ... }:

{
  imports = [
    ./modules/nixos/desktop.nix
    ./modules/nixos/hardware.nix
    ./modules/nixos/fonts.nix
    ./modules/nixos/nix.nix
    ./modules/nixos/utils.nix
  ];

  # --- Boot & Kernel ---
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "exfat" ];
  boot.kernelPackages = pkgs.linuxPackages_zen;

  # --- Networking ---
  networking.networkmanager.enable = true;
  networking.firewall.enable = true;
  
  # --- Time & Localization ---
  time.timeZone = "America/New_York";

  # --- User Configuration ---
  users.users.barthmalemew = {
    isNormalUser = true;
    description = "Kevin Rouse";
    extraGroups = [ "wheel" "networkmanager" ]; 
    openssh.authorizedKeys.keys = [
      (builtins.readFile ./ssh/id_ed25519.pub)
    ];
  };

  system.stateVersion = "24.11";
}
