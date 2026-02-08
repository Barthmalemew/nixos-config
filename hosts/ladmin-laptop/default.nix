{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../configuration.nix
    ../../modules/nixos/power.nix
  ];

  networking.hostName = "ladmin-laptop";

  nixpkgs.hostPlatform = "x86_64-linux";

  theme.isLaptop = true;
  theme.primaryMonitor = "eDP-1";

  # --- Power Management (Overrides) ---
  # thermald prevents overheating on Intel CPUs
  services.thermald.enable = true;
  
  # Power profiles daemon conflicts with TLP
  services.power-profiles-daemon.enable = false;

  # Laptop-specific hardware tweaks
  services.libinput.enable = true; # Required for touchpad support in most places

  # --- Monitor Layout ---
  theme.monitors = {
    "internal" = {
      name = "eDP-1";
      mode = "2880x1800@120.000";
      scale = 1.666667;
    };
  };
}
