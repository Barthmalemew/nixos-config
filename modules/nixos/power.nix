{ config, lib, pkgs, ... }:

{
  # ---------------------------------------------------------------------------
  # ADVANCED POWER MANAGEMENT (TLP)
  # ---------------------------------------------------------------------------
  # We use TLP instead of auto-cpufreq because it provides deeper optimization
  # for non-CPU components (PCIe, WiFi, USB, Audio).

  services.tlp = {
    enable = true;
    settings = {
      # CPU scaling governor
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      # CPU energy/performance policy
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";

      # Intel CPU turbo boost (Disable on battery to save significant power)
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;

      # Wireless power saving
      WIFI_PWR_ON_AC = "off";
      WIFI_PWR_ON_BAT = "on";

      # PCIe Active State Power Management
      PCIE_ASPM_ON_AC = "performance";
      PCIE_ASPM_ON_BAT = "powersave";

      # Audio power saving
      SOUND_POWER_SAVE_ON_AC = 0;
      SOUND_POWER_SAVE_ON_BAT = 1;
      
      # We respect the "no battery thresholds" rule.
      # Charging is handled by the default hardware controller.
    };
  };

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
  # If battery < 20% and discharging, it forces the system into "Low Power" mode.

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
          # Force CPU to ultra-low power
          ${pkgs.tlp}/bin/tlp bat
        fi
      '';
    };
  };

  # Trigger the script whenever battery state changes.
  # udev can't do numeric comparisons reliably, so we run on change and let the
  # oneshot script decide whether to act.
  services.udev.extraRules = ''
    ACTION=="change", SUBSYSTEM=="power_supply", KERNEL=="BAT*", RUN+="${pkgs.systemd}/bin/systemctl start battery-monitor.service"
  '';

  # Power Management tools
  environment.systemPackages = with pkgs; [
    powertop # For manual monitoring
    tlp
  ];
}
