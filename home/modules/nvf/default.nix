{ config, pkgs, inputs, ... }:

{
  programs.nvf = {
    enable = true;
    
    settings = {
      vim = {
        viAlias = true;
        vimAlias = true;
        
        # Line numbers
        lineNumberMode = "number";
        
        # Indentation
        tabWidth = 2;
        autoIndent = true;
        
        # Basic settings
        useSystemClipboard = true;
        syntaxHighlighting = true;
        
        # Leader key
        leaderKey = " ";
        
        # Theme
        theme = {
          enable = true;
          name = "catppuccin";
          style = "mocha";
        };
      };
    };
  };
}
