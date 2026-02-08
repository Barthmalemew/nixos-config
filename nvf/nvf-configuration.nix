{ pkgs, ... }:

{
  vim = {
    viAlias = true;
    vimAlias = true;

    lineNumberMode = "number";

    clipboard = {
      enable = true;
      providers = {
        "wl-copy".enable = true;
      };
    };

    spellcheck.enable = false;

    options = {
      tabstop = 2;
      shiftwidth = 2;
      expandtab = true;
      softtabstop = 2;
    };

    theme = {
      enable = true;
      name = "base16";
      style = "dark";
      # base16-colors are injected by the flake.nix wrapper
    };

    treesitter.enable = true;
    telescope = {
      enable = true;
      mappings = {
        findFiles = "<leader>ff";
        liveGrep = "<leader>fg";
        buffers = "<leader>fb";
        helpTags = "<leader>fh";
        gitCommits = "<leader>gc";
      };
    };

    git.gitsigns.enable = true;
    autopairs.nvim-autopairs.enable = true;

    # Completion + snippets
    autocomplete.nvim-cmp.enable = true;
    snippets.luasnip.enable = true;

    # LSP
    lsp = {
      enable = true;
      lspconfig.enable = true;
    };

    # Languages
    languages = {
      nix.enable = true;

      python = {
        enable = true;
        lsp.enable = true;
        treesitter.enable = true;
        format.enable = true;
        format.type = ["black"];
      };

      clang = {
        enable = true;
        lsp.enable = true;
      };
    };

    statusline.lualine.enable = true;
  };
}
