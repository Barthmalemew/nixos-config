{ lib, pkgs, username, ... }:

{
  # Boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 3;
  boot.kernelPackages = pkgs.linuxPackages_zen;

  # Networking
  networking.networkmanager.enable = true;
  hardware.bluetooth.enable = true;
  services.fwupd.enable = true;

  # Localization — override time.timeZone per-host if needed
  time.timeZone = lib.mkDefault "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  # Nix settings
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  nixpkgs.config.allowUnfree = true;

  # Niri compositor
  programs.niri.enable = true;

  # Display manager
  services.xserver.enable = true;
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  # XDG portal
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.kdePackages.xdg-desktop-portal-kde
      pkgs.xdg-desktop-portal-gnome
    ];
    config.common = {
      default = "kde";
      "org.freedesktop.portal.ScreenCast" = "gnome";
      "org.freedesktop.portal.Screenshot" = "gnome";
      "org.freedesktop.portal.RemoteDesktop" = "gnome";
    };
  };

  # Audio
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Fonts
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-color-emoji
    pkgs."nerd-fonts".jetbrains-mono
  ];

  # System packages
  environment.systemPackages = with pkgs; [
    git
    wget
    curl
    wl-clipboard
  ];

  # Bash — bashInteractive is already in /etc/shells by default on NixOS.
  # home-manager's programs.bash manages ~/.bashrc / ~/.bash_profile.
  users.users.${username}.shell = pkgs.bashInteractive;

  # SSH
  services.openssh.enable = true;
  services.openssh.settings = {
    PermitRootLogin = "no";
    PasswordAuthentication = false;
  };
}
