{ colorscheme, ... }:

let
  c = colorscheme;
  # foot wants hex without the leading '#'
  strip = s: builtins.substring 1 (builtins.stringLength s - 1) s;
in
{
  programs.foot = {
    enable = true;

    settings = {
      main = {
        term = "xterm-256color";
        font = "monospace:size=11";
        pad = "8x8";
      };

      colors = {
        foreground = strip c.text;
        background = strip c.base;
        cursor = "${strip c.base} ${strip c.text}";

        selection-foreground = strip c.text;
        selection-background = strip c.highlightMed;

        # Regular colors (0-7)
        regular0 = strip c.base;         # black
        regular1 = strip c.red;          # red
        regular2 = strip c.green;        # green  (ANSI programs expect this)
        regular3 = strip c.orange;       # yellow
        regular4 = strip c.muted;        # blue   (no blue — use gray)
        regular5 = strip c.red;          # magenta (use red)
        regular6 = strip c.subtle;       # cyan   (no cyan — use light gray)
        regular7 = strip c.subtle;       # white

        # Bright colors (8-15)
        bright0 = strip c.muted;         # bright black
        bright1 = strip c.orange;        # bright red
        bright2 = strip c.greenDim;      # bright green
        bright3 = strip c.orange;        # bright yellow
        bright4 = strip c.subtle;        # bright blue  (gray)
        bright5 = strip c.orange;        # bright magenta (orange)
        bright6 = strip c.subtle;        # bright cyan  (gray)
        bright7 = strip c.text;          # bright white
      };
    };
  };
}
