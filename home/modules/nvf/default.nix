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
        options = {
          tabstop = 2;
          shiftwidth = 2;
          autoindent = true;
        };
        
        # Basic settings
        syntaxHighlighting = true;

        clipboard.registers = [ "unnamedplus" ];
        
        globals.mapleader = " ";

        telescope.enable = true;
        
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
