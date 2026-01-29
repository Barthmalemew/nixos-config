{ config, lib, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 3;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "exfat" ];

  # Kernel
  boot.kernelPackages = pkgs.linuxPackages_zen;

  # Networking
  networking.hostName = "ladmin";
  networking.networkmanager.enable = true;

  time.timeZone = "America/New_York";

  # Users
  users.users.barthmalemew = {
    isNormalUser = true;
    description = "Kevin Rouse";
    extraGroups = [ "wheel" "networkmanager" ]; 
    packages = with pkgs; [];
  };

  nixpkgs.config.allowUnfree = true;

  # Display Manager & Desktop
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  programs.niri.enable = true;
  programs.xwayland.enable = true;

  # System Packages
  environment.systemPackages = with pkgs; [
    xwayland
    wofi
    foot
    yazi
    vim 
    wget
    git
    swaylock
    udiskie
    gvfs
    brightnessctl
    playerctl
    pavucontrol
    kdePackages.dolphin
    kdePackages.qtsvg
    kdePackages.polkit-kde-agent-1
  ];

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    QT_QPA_PLATFORM = "wayland;xcb";
    GDK_BACKEND = "wayland,x11";
    SDL_VIDEODRIVER = "wayland";
    CLUTTER_BACKEND = "wayland";
  };

  xdg.portal = {
    enable = true;
    # Prefer KDE dialogs, but keep GTK as fallback.
    extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde pkgs.xdg-desktop-portal-gtk ];
    config.common.default = [ "kde" "gtk" ];
  };

  # Services
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;
  services.thermald.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;

  # Audio
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Firmware
  hardware.enableRedistributableFirmware = true;
  hardware.firmware = with pkgs; [
    sof-firmware
  ];

  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "25.11";
}
