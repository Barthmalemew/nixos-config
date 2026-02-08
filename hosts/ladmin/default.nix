{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../configuration.nix
  ];

  networking.hostName = "ladmin";

  nixpkgs.hostPlatform = "x86_64-linux";

  theme.isLaptop = false;
  theme.primaryMonitor = "DP-1";

  # --- Power Management ---
  # On a desktop, we want performance over power saving.
  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";

  # --- Monitor Layout ---
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
