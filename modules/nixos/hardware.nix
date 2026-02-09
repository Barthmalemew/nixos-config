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
