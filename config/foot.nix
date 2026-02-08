{ config, pkgs, ... }:

let
  palette = config.theme.colors;

  stripHash = s: builtins.replaceStrings [ "#" ] [ "" ] s;
  c = s: stripHash s;

in
{
  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "JetBrainsMono Nerd Font:size=11";
        pad = "12x12";
      };

      # foot expects hex without `#`
      colors = {
        background = c palette.background;
        foreground = c palette.foreground;

        regular0 = c palette.panelBg;
        regular1 = c palette.red;
        regular2 = c palette.orange;
        regular3 = c palette.darkRed;
        regular4 = c palette.green;
        regular5 = c palette.highlight;
        regular6 = c palette.orange;
        regular7 = c palette.foreground;

        bright0 = c palette.dim;
        bright1 = c palette.highlight;
        bright2 = c palette.orange;
        bright3 = c palette.orange;
        bright4 = c palette.red;
        bright5 = c palette.orange;
        bright6 = c palette.foreground;
        bright7 = c palette.foreground;
      };

      csd = {
        preferred = "none";
      };
    };
  };
}