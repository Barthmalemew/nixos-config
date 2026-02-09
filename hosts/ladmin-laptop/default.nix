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

  # Laptop-specific hardware tweaks
  services.libinput.enable = true; # Required for touchpad support

  # --- Monitor Layout ---
  theme.monitors = {
    "internal" = {
      name = "eDP-1";
      mode = "2880x1800@120.000";
      scale = 1.666667;
    };
  };
}
