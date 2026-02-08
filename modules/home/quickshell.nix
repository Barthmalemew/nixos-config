{ config, lib, pkgs, ... }:

let
  theme = config.theme.colors;
  
  # Find the primary monitor config
  primaryMonitorCfg = lib.findFirst (m: m.name == config.theme.primaryMonitor) {} (lib.attrValues config.theme.monitors);
  
  # Extract height from mode string like "2880x1800@120.000"
  # We do this by splitting on '@' then 'x' and taking the second element.
  heightStr = if primaryMonitorCfg ? mode && primaryMonitorCfg.mode != null 
              then lib.last (lib.splitString "x" (lib.head (lib.splitString "@" primaryMonitorCfg.mode)))
              else "1080";
              
  height = lib.toInt heightStr;
  
  # Nix float calculation
  calcScale = h: (1.0 * h) / 1080.0;
  scale = calcScale height;

  # Absolute paths for assets to ensure they load reliably via Systemd
  asukaPath = ../../config/quickshell/assets/asuka.png;
  maskPath = ../../config/quickshell/assets/unit2-foreground.png;
in

{
  # ---------------------------------------------------------------------------
  # QUICKSHELL CONFIGURATION
  # ---------------------------------------------------------------------------
  # Keep QML files as-is in config/quickshell; only inject theme colors here.

  xdg.configFile."quickshell" = {
    source = ../../config/quickshell;
    recursive = true;
  };

  xdg.configFile."quickshell/theme/Colors.qml".text = ''
    import QtQuick

    QtObject {
      readonly property bool isLaptop: ${if config.theme.isLaptop then "true" else "false"}
      readonly property string primaryMonitor: "${config.theme.primaryMonitor}"
      readonly property real scale: ${toString scale}

      # Absolute Asset Paths
      readonly property url asukaPath: "file://${asukaPath}"
      readonly property url maskPath: "file://${maskPath}"

      readonly property string background: "${theme.background}"
      readonly property string foreground: "${theme.foreground}"
      readonly property string cursor: "${theme.cursor}"

      readonly property string panelBg: "${theme.panelBg}"
      readonly property string panelBg2: "${theme.panelBg2}"
      readonly property string panelBorder: "${theme.panelBorder}"
      readonly property string muted: "${theme.muted}"
      readonly property string outline: "${theme.outline}"

      # Tactical Elements
      readonly property string launcherOverlay: "#cc000000"
      readonly property string emptyRail: "#151618"
      readonly property string darkSurface: "#080809"
      readonly property string midSurface: "#141518"
      readonly property string deepSurface: "#0b0b0c"

      readonly property string clockHour: "${theme.red}"
      readonly property string clockMinute: "${theme.red}"
      readonly property string clock: "${theme.red}"

      readonly property string color0: "${theme.panelBg}"
      readonly property string color1: "${theme.red}"
      readonly property string color2: "${theme.orange}"
      readonly property string color3: "${theme.darkRed}"
      readonly property string color4: "${theme.green}"
      readonly property string color5: "${theme.highlight}"
      readonly property string color6: "${theme.orange}"
      readonly property string color7: "${theme.foreground}"
      readonly property string color8: "${theme.dim}"
      readonly property string color9: "${theme.highlight}"
      readonly property string color10: "${theme.orange}"
      readonly property string color11: "${theme.orange}"
      readonly property string color12: "${theme.red}"
      readonly property string color13: "${theme.orange}"
      readonly property string color14: "${theme.foreground}"
      readonly property string color15: "${theme.foreground}"

      readonly property string black: "#000000"
      readonly property string red: color1
      readonly property string green: color4
      readonly property string yellow: color5
      readonly property string blue: color4
      readonly property string magenta: color5
      readonly property string cyan: color6
      readonly property string white: foreground

      readonly property string brightBlack: color8
      readonly property string brightRed: color1
      readonly property string brightGreen: color4
      readonly property string brightYellow: color11
      readonly property string brightBlue: color12
      readonly property string brightMagenta: color5
      readonly property string brightCyan: color6
      readonly property string brightWhite: foreground
    }
  '';
}
