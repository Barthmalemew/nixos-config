{ pkgs, ... }:

{
  # Power management — power-profiles-daemon is recommended for Intel Lunar Lake (Core Ultra 200V).
  # It works with the kernel's built-in EAS; TLP/thermald conflict with its efficiency-core scheduling.
  services.power-profiles-daemon.enable = true;

  # Deep sleep (S3) instead of s2idle for better suspend battery life
  boot.kernelParams = [ "mem_sleep_default=deep" ];

  # Battery and power status (used by quickshell battery widget)
  services.upower.enable = true;

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
