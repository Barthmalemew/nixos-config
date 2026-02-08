{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../configuration.nix
  ];

  networking.hostName = "ladmin-laptop";

  # Power Management - Laptop Specific
  # thermald prevents overheating on Intel CPUs
  services.thermald.enable = true;
  
  # auto-cpufreq handles dynamic frequency scaling based on battery/AC state
  # Note: This conflicts with services.power-profiles-daemon, so we disable it.
  services.power-profiles-daemon.enable = false;
  services.auto-cpufreq.enable = true;
  services.auto-cpufreq.settings = {
    battery = {
       governor = "powersave";
       turbo = "never";
    };
    charger = {
       governor = "performance";
       turbo = "auto";
    };
  };

  # Powertop auto-tune on startup to squeeze more battery life
  powerManagement.powertop.enable = true;

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
