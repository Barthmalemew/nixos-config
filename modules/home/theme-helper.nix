{ lib, osConfig, ... }:

let
  colors = osConfig.theme.colors;
  font = osConfig.theme.font;
  monitors = lib.attrValues osConfig.theme.monitors;
  primaryMonitorName = osConfig.theme.primaryMonitor;
  primaryMonitorCfg = lib.findFirst (m: m.name == primaryMonitorName) {} monitors;
in

{
  inherit colors font monitors primaryMonitorCfg primaryMonitorName;
}
