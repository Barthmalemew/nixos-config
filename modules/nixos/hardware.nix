{ config, lib, pkgs, ... }:

{
  # --- Hardware & Services ---
  services.upower.enable = true;
  services.power-profiles-daemon.enable = lib.mkDefault true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;

  # Firmware updates (default on laptops; override per-host if desired).
  services.fwupd.enable = lib.mkDefault config.theme.isLaptop;

  # Bluetooth support (default off; enable per-host if needed).
  hardware.bluetooth.enable = lib.mkDefault false;
  hardware.bluetooth.powerOnBoot = lib.mkDefault false;

  # --- Graphics & Video Acceleration ---
  # Best-practice Intel hardware acceleration for modern chips (Lunar Lake).
  # intel-media-driver provides VA-API support for Gen8+.
  # vpl-gpu-rt is the modern OneVPL runtime required for Core Ultra chips.
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver
      vpl-gpu-rt
      intel-compute-runtime
    ];
  };
  
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  hardware.enableRedistributableFirmware = true;
  hardware.firmware = with pkgs; [
    sof-firmware
  ];
}
