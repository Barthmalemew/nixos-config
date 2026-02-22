{ colorscheme, ... }:

let
  c = colorscheme;
in
{
  programs.wezterm = {
    enable = true;
    enableBashIntegration = false;

    extraConfig = ''
      local wezterm = require("wezterm")

      return {
        term = "xterm-256color",
        font_size = 11.0,
        enable_tab_bar = false,
        keys = {
          { key = "c", mods = "CTRL|SHIFT", action = wezterm.action.CopyTo "Clipboard" },
          { key = "v", mods = "CTRL|SHIFT", action = wezterm.action_callback(function(window, pane)
              local ok, stdout, _ = wezterm.run_child_process({ "wl-paste", "--no-newline" })
              if ok then pane:send_text(stdout) end
            end) },
          { key = "v", mods = "ALT", action = wezterm.action.SplitPane { direction = "Right", size = { Percent = 50 } } },
          { key = "s", mods = "ALT", action = wezterm.action.SplitPane { direction = "Down", size = { Percent = 50 } } },
          { key = "h", mods = "ALT", action = wezterm.action.ActivatePaneDirection("Left") },
          { key = "j", mods = "ALT", action = wezterm.action.ActivatePaneDirection("Down") },
          { key = "k", mods = "ALT", action = wezterm.action.ActivatePaneDirection("Up") },
          { key = "l", mods = "ALT", action = wezterm.action.ActivatePaneDirection("Right") },
          { key = "H", mods = "ALT|SHIFT", action = wezterm.action.AdjustPaneSize({ "Left", 3 }) },
          { key = "J", mods = "ALT|SHIFT", action = wezterm.action.AdjustPaneSize({ "Down", 3 }) },
          { key = "K", mods = "ALT|SHIFT", action = wezterm.action.AdjustPaneSize({ "Up", 3 }) },
          { key = "L", mods = "ALT|SHIFT", action = wezterm.action.AdjustPaneSize({ "Right", 3 }) },
          { key = "q", mods = "ALT", action = wezterm.action.CloseCurrentPane { confirm = true } },
          { key = "f", mods = "ALT", action = wezterm.action.TogglePaneZoomState },
          { key = "t", mods = "CTRL|SHIFT", action = wezterm.action.DisableDefaultAssignment },
          { key = "t", mods = "SUPER", action = wezterm.action.DisableDefaultAssignment },
        },
        window_padding = {
          left = 8,
          right = 8,
          top = 8,
          bottom = 8,
        },
        colors = {
          foreground = "${c.text}",
          background = "${c.base}",
          cursor_bg = "${c.text}",
          cursor_fg = "${c.base}",
          selection_fg = "${c.text}",
          selection_bg = "${c.highlightMed}",
          ansi = {
            "${c.base}",
            "${c.red}",
            "${c.green}",
            "${c.orange}",
            "${c.muted}",
            "${c.red}",
            "${c.subtle}",
            "${c.subtle}",
          },
          brights = {
            "${c.muted}",
            "${c.orange}",
            "${c.greenDim}",
            "${c.orange}",
            "${c.subtle}",
            "${c.orange}",
            "${c.subtle}",
            "${c.text}",
          },
        },
      }
    '';
  };
}
