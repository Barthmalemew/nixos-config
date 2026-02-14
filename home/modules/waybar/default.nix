{ ... }:

{
  programs.waybar = {
    enable = true;
    systemd.enable = true;

    settings = [
      {
        layer = "top";
        position = "top";
        height = 30;
        spacing = 8;

        modules-left = [ "niri/workspaces" "niri/window" ];
        modules-center = [ "clock" ];
        modules-right = [ "network" "pulseaudio" "battery" "tray" ];

        "clock" = {
          format = "{:%a %b %d  %H:%M}";
          tooltip-format = "{:%Y-%m-%d %H:%M:%S}";
        };

        "battery" = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{capacity}% {icon}";
          format-icons = [ "" "" "" "" "" ];
        };

        "network" = {
          format-wifi = "{essid} ({signalStrength}%)";
          format-ethernet = "{ifname}";
          format-disconnected = "offline";
          tooltip-format = "{ipaddr}/{cidr}";
        };

        "pulseaudio" = {
          format = "{volume}% {icon}";
          format-muted = "muted";
          format-icons = {
            default = [ "" "" "" ];
          };
        };

        "tray" = {
          spacing = 8;
        };
      }
    ];

    style = ''
      * {
        border: none;
        border-radius: 0;
        font-family: "JetBrainsMono Nerd Font";
        font-size: 12px;
        min-height: 0;
      }

      window#waybar {
        background: rgba(24, 24, 37, 0.95);
        color: #cdd6f4;
      }

      #workspaces {
        margin: 0 8px;
      }

      #workspaces button {
        color: #6c7086;
        padding: 0 6px;
      }

      #workspaces button.active {
        color: #f38ba8;
      }

      #clock,
      #network,
      #pulseaudio,
      #battery,
      #tray,
      #window {
        margin: 0 8px;
      }
    '';
  };
}
