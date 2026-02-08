{ lib, pkgs, ... }:

{
  # --- Hardware & Services ---
  services.upower.enable = true;
  services.power-profiles-daemon.enable = lib.mkDefault true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;
  
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
