{ config, lib, pkgs, ... }:

{
  # ---------------------------------------------------------------------------
  # BEST-PRACTICE POWER MANAGEMENT (Power Profiles Daemon)
  # ---------------------------------------------------------------------------
  # For modern Intel (Lunar Lake), power-profiles-daemon is the industry standard.
  # It integrates with Intel HWP (Hardware P-States) and allows the hardware
  # to manage its own power-saving 'Islands' much more efficiently than TLP.

  services.power-profiles-daemon.enable = true;
  services.tlp.enable = false;

  # thermald prevents overheating and helps with battery life on Intel CPUs.
  services.thermald.enable = true;

  # Compressed RAM swap helps on systems with no disk swap.
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  # Sensible laptop lid behavior.
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
  };

  # ---------------------------------------------------------------------------
  # THE "20% PANIC" TRIGGER
  # ---------------------------------------------------------------------------
  # A small script that runs when the battery state changes. 
  # If battery < 20% and discharging, it forces the system into "power-saver" mode.

  systemd.services.battery-monitor = {
    description = "Monitor battery for 20% panic mode";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "battery-panic" ''
        # Find the first battery device
        BAT_PATH=$(ls -d /sys/class/power_supply/BAT* | head -n 1)
        if [ -z "$BAT_PATH" ]; then exit 0; fi

        BAT=$(cat "$BAT_PATH/capacity")
        STAT=$(cat "$BAT_PATH/status")

        if [ "$STAT" = "Discharging" ] && [ "$BAT" -le 20 ]; then
          echo "Battery Critical ($BAT%): Enabling Panic Mode"
          # Drop brightness to 20%
          ${pkgs.brightnessctl}/bin/brightnessctl s 20%
          # Switch to power-saver profile
          ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set power-saver
        fi
      '';
    };
  };

  # Trigger the script whenever battery state changes.
  services.udev.extraRules = ''
    ACTION=="change", SUBSYSTEM=="power_supply", KERNEL=="BAT*", RUN+="${pkgs.systemd}/bin/systemctl start battery-monitor.service"
  '';

  # Power Management tools
  environment.systemPackages = with pkgs; [
    powertop 
    power-profiles-daemon
  ];
}
