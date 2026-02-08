{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../configuration.nix
  ];

  networking.hostName = "ladmin";

  # Power Management - Desktop Specific
  # On a desktop, we want performance over power saving.
  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";

  # Define monitor layout for the Desktop
  theme.monitors = {
    "primary" = {
      name = "DP-1";
      mode = "2560x1440@165.000";
      position = "x=1440 y=0";
    };
    "secondary" = {
      name = "DP-2";
      mode = "2560x1440";
      transform = "90";
      position = "x=0 y=-795";
    };
  };
}
