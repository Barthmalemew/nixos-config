{ config, pkgs, ... }:

{
  # Power management
  powerManagement.enable = true;

  boot.kernelParams = [ "mem_sleep_default=deep" ];

  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      PLATFORM_PROFILE_ON_AC = "performance";
      PLATFORM_PROFILE_ON_BAT = "low-power";
    };
  };

  services.thermald.enable = true;

  environment.systemPackages = with pkgs; [
    powertop
  ];

  # Touchpad
  services.libinput = {
    enable = true;
    touchpad.naturalScrolling = true;
    touchpad.tapping = true;
  };
}
