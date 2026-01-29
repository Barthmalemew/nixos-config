{ ... }:

{
  home.file.".config/opencode/config.json".text = ''
    {
      "$schema": "https://opencode.ai/config.json",
      "plugin": ["opencode-gemini-auth@latest"],
      "permission": {
        "read": "allow",
        "list": "allow",
        "glob": "allow",
        "grep": "allow",

        "edit": "ask",
        "bash": "ask",
        "task": "ask",
        "webfetch": "ask",
        "external_directory": "ask"
      }
    }
  '';
}
