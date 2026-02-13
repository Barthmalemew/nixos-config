{ pkgs, ... }:

let
  opencodeConfig = {
    "$schema" = "https://opencode.ai/config.json";
    permission = {
      bash = "ask";
      edit = "ask";
      external_directory = "ask";
      glob = "allow";
      grep = "allow";
      list = "allow";
      read = "allow";
      task = "ask";
      webfetch = "ask";
    };
    plugin = [
      "opencode-gemini-auth@latest"
      "./plugins/mandrid-pack.js"
    ];
  };
in
{
  home.packages = [ pkgs.opencode ];

  xdg.configFile."opencode/opencode.json".text = builtins.toJSON opencodeConfig;
  xdg.configFile."opencode/config.json".text = builtins.toJSON opencodeConfig;
}
