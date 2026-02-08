{ pkgs, ... }:

{
  # Use xdg.configFile for cleaner paths (automatically maps to ~/.config/...)
  # Use builtins.toJSON to ensure valid JSON generation from Nix data structures.
  xdg.configFile."opencode/config.json".text = builtins.toJSON {
    "$schema" = "https://opencode.ai/config.json";
    plugin = [ "opencode-gemini-auth@latest" ];
    
    permission = {
      read = "allow";
      list = "allow";
      glob = "allow";
      grep = "allow";

      edit = "ask";
      bash = "ask";
      task = "ask";
      webfetch = "ask";
      external_directory = "ask";
    };
  };
}
