{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../configuration.nix
  ];

  networking.hostName = "ladmin-laptop";

  # Define monitor layout for the Laptop
  theme.monitors = {
    "internal" = {
      name = "eDP-1";
      mode = "2880x1800@120.000";
      scale = 1.666667;
    };
  };

  services.thermald.enable = true;
}
