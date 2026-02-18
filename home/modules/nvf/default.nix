{ colorscheme, lib, ... }:

let
  c = colorscheme;
in
{
  programs.nvf = {
    enable = true;

    settings = {
      vim = {
        viAlias = true;
        vimAlias = true;

        lineNumberMode = "number";

        options = {
          tabstop = 2;
          shiftwidth = 2;
          autoindent = true;
        };

        syntaxHighlighting = true;
        clipboard.registers = [ "unnamedplus" ];
        globals.mapleader = " ";
        telescope.enable = true;

        lsp = {
          enable = true;
          formatOnSave = false;
          inlayHints.enable = false;

          mappings = {
            goToDefinition = "gd";
            goToDeclaration = "gD";
            goToType = "<leader>D";
            listImplementations = "gI";
            listReferences = "gr";
            hover = "K";
            renameSymbol = "<leader>rn";
            codeAction = "<leader>ca";
            previousDiagnostic = "[d";
            nextDiagnostic = "]d";
            openDiagnosticFloat = "<leader>e";
          };

          servers = {
            jdtls.enable = lib.mkForce false;
            csharp_ls.enable = lib.mkForce false;
          };
        };

        diagnostics = {
          enable = true;
          config = {
            virtual_text = false;
            virtual_lines = false;
            signs = true;
            underline = true;
            update_in_insert = false;
            float = {
              border = "rounded";
              source = "if_many";
            };
          };
        };

        languages = {
          enableTreesitter = true;
          enableFormat = false;
          enableExtraDiagnostics = false;

          nix = {
            enable = true;
            lsp.servers = [ "nixd" ];
          };

          lua.enable = true;
          ts.enable = true;
          python = {
            enable = true;
            lsp.servers = [ "pyright" ];
          };
          rust.enable = true;
          go.enable = true;
          clang.enable = true;
          assembly.enable = true;
          html.enable = true;
          css.enable = true;
          java.enable = true;
          csharp.enable = true;
        };

        # Disable built-in theme — custom palette from colorscheme.nix
        theme.enable = false;

        luaConfigRC.lspRuntimeGuards = ''
          local nvf_runtime_warnings = {}

          local function warn_once(key, message)
            if nvf_runtime_warnings[key] then
              return
            end
            nvf_runtime_warnings[key] = true
            vim.notify(message, vim.log.levels.WARN)
          end

          local function start_named_server(server)
            local config = vim.lsp.config[server]
            if not config then
              vim.notify(string.format("LSP server '%s' is not configured.", server), vim.log.levels.ERROR)
              return
            end

            vim.lsp.enable(server)
            vim.lsp.start(config, { bufnr = vim.api.nvim_get_current_buf() })
          end

          vim.api.nvim_create_user_command("LspStartJava", function()
            if vim.fn.executable("java") ~= 1 then
              warn_once(
                "java-runtime-missing",
                "jdtls skipped: no Java runtime found in this environment. Enter the project's dev shell, then run :LspStartJava again."
              )
              return
            end

            start_named_server("jdtls")
          end, { desc = "Start Java LSP (jdtls)" })

          vim.api.nvim_create_user_command("LspStartCSharp", function()
            if vim.fn.executable("dotnet") ~= 1 then
              warn_once(
                "dotnet-runtime-missing",
                "csharp_ls skipped: no dotnet runtime found in this environment. Enter the project's dev shell, then run :LspStartCSharp again."
              )
              return
            end

            start_named_server("csharp_ls")
          end, { desc = "Start C# LSP (csharp_ls)" })
        '';

        luaConfigRC.customTheme = ''
          vim.o.termguicolors = true
          vim.cmd("highlight clear")
          if vim.fn.exists("syntax_on") then
            vim.cmd("syntax reset")
          end
          vim.g.colors_name = "system"

          local hi = function(group, opts)
            vim.api.nvim_set_hl(0, group, opts)
          end

          -- Base UI
          hi("Normal",        { fg = "${c.text}", bg = "${c.base}" })
          hi("NormalFloat",   { fg = "${c.text}", bg = "${c.overlay}" })
          hi("FloatBorder",   { fg = "${c.muted}", bg = "${c.overlay}" })
          hi("CursorLine",    { bg = "${c.highlightLow}" })
          hi("CursorColumn",  { bg = "${c.highlightLow}" })
          hi("ColorColumn",   { bg = "${c.highlightLow}" })
          hi("LineNr",        { fg = "${c.muted}" })
          hi("CursorLineNr",  { fg = "${c.orange}", bold = true })
          hi("Visual",        { bg = "${c.highlightMed}" })
          hi("VisualNOS",     { bg = "${c.highlightMed}" })
          hi("Search",        { fg = "${c.base}", bg = "${c.orange}" })
          hi("IncSearch",     { fg = "${c.base}", bg = "${c.red}" })
          hi("CurSearch",     { fg = "${c.base}", bg = "${c.red}" })
          hi("Substitute",    { fg = "${c.base}", bg = "${c.red}" })

          -- Status / Tab / Window
          hi("StatusLine",    { fg = "${c.text}", bg = "${c.surface}" })
          hi("StatusLineNC",  { fg = "${c.muted}", bg = "${c.overlay}" })
          hi("TabLine",       { fg = "${c.muted}", bg = "${c.overlay}" })
          hi("TabLineFill",   { bg = "${c.base}" })
          hi("TabLineSel",    { fg = "${c.text}", bg = "${c.surface}", bold = true })
          hi("WinSeparator",  { fg = "${c.muted}" })
          hi("VertSplit",     { fg = "${c.muted}" })

          -- Popup menu
          hi("Pmenu",         { fg = "${c.text}", bg = "${c.overlay}" })
          hi("PmenuSel",      { fg = "${c.base}", bg = "${c.orange}" })
          hi("PmenuSbar",     { bg = "${c.surface}" })
          hi("PmenuThumb",    { bg = "${c.muted}" })

          -- Messages
          hi("ErrorMsg",      { fg = "${c.red}", bold = true })
          hi("WarningMsg",    { fg = "${c.orange}", bold = true })
          hi("MoreMsg",       { fg = "${c.subtle}" })
          hi("Question",      { fg = "${c.subtle}" })
          hi("ModeMsg",       { fg = "${c.text}", bold = true })

          -- Folds / Diff
          hi("Folded",        { fg = "${c.subtle}", bg = "${c.highlightLow}" })
          hi("FoldColumn",    { fg = "${c.muted}" })
          hi("SignColumn",    { fg = "${c.muted}" })
          hi("DiffAdd",       { bg = "#1a2e1a" })
          hi("DiffChange",    { bg = "#2a2218" })
          hi("DiffDelete",    { fg = "${c.red}", bg = "#2a1418" })
          hi("DiffText",      { bg = "${c.highlightMed}" })

          -- Misc UI
          hi("NonText",       { fg = "${c.muted}" })
          hi("SpecialKey",    { fg = "${c.muted}" })
          hi("Directory",     { fg = "${c.orange}" })
          hi("Title",         { fg = "${c.orange}", bold = true })
          hi("Conceal",       { fg = "${c.muted}" })
          hi("MatchParen",    { fg = "${c.orange}", bg = "${c.highlightMed}", bold = true })
          hi("EndOfBuffer",   { fg = "${c.muted}" })

          -- Syntax
          hi("Comment",       { fg = "${c.muted}", italic = true })
          hi("Constant",      { fg = "${c.red}" })
          hi("String",        { fg = "${c.orange}" })
          hi("Character",     { fg = "${c.orange}" })
          hi("Number",        { fg = "${c.red}" })
          hi("Boolean",       { fg = "${c.red}" })
          hi("Float",         { fg = "${c.red}" })
          hi("Identifier",    { fg = "${c.text}" })
          hi("Function",      { fg = "${c.orange}" })
          hi("Statement",     { fg = "${c.red}" })
          hi("Conditional",   { fg = "${c.red}" })
          hi("Repeat",        { fg = "${c.red}" })
          hi("Label",         { fg = "${c.orange}" })
          hi("Operator",      { fg = "${c.subtle}" })
          hi("Keyword",       { fg = "${c.red}" })
          hi("Exception",     { fg = "${c.red}" })
          hi("PreProc",       { fg = "${c.orange}" })
          hi("Include",       { fg = "${c.red}" })
          hi("Define",        { fg = "${c.orange}" })
          hi("Macro",         { fg = "${c.orange}" })
          hi("PreCondit",     { fg = "${c.orange}" })
          hi("Type",          { fg = "${c.orange}" })
          hi("StorageClass",  { fg = "${c.red}" })
          hi("Structure",     { fg = "${c.orange}" })
          hi("Typedef",       { fg = "${c.orange}" })
          hi("Special",       { fg = "${c.red}" })
          hi("SpecialChar",   { fg = "${c.red}" })
          hi("Tag",           { fg = "${c.orange}" })
          hi("Delimiter",     { fg = "${c.subtle}" })
          hi("SpecialComment",{ fg = "${c.muted}", italic = true })
          hi("Debug",         { fg = "${c.red}" })
          hi("Underlined",    { fg = "${c.subtle}", underline = true })
          hi("Error",         { fg = "${c.red}" })
          hi("Todo",          { fg = "${c.orange}", bg = "${c.highlightLow}", bold = true })

          -- Treesitter
          hi("@variable",             { fg = "${c.text}" })
          hi("@variable.builtin",     { fg = "${c.red}" })
          hi("@variable.parameter",   { fg = "${c.red}" })
          hi("@constant",             { fg = "${c.red}" })
          hi("@constant.builtin",     { fg = "${c.orange}" })
          hi("@module",               { fg = "${c.subtle}" })
          hi("@string",               { fg = "${c.orange}" })
          hi("@string.escape",        { fg = "${c.red}" })
          hi("@character",            { fg = "${c.orange}" })
          hi("@number",               { fg = "${c.red}" })
          hi("@boolean",              { fg = "${c.red}" })
          hi("@float",                { fg = "${c.red}" })
          hi("@function",             { fg = "${c.orange}" })
          hi("@function.builtin",     { fg = "${c.orange}" })
          hi("@function.call",        { fg = "${c.orange}" })
          hi("@function.method",      { fg = "${c.orange}" })
          hi("@function.method.call", { fg = "${c.orange}" })
          hi("@constructor",          { fg = "${c.red}" })
          hi("@keyword",              { fg = "${c.red}" })
          hi("@keyword.function",     { fg = "${c.red}" })
          hi("@keyword.return",       { fg = "${c.red}" })
          hi("@keyword.operator",     { fg = "${c.red}" })
          hi("@keyword.conditional",  { fg = "${c.red}" })
          hi("@keyword.repeat",       { fg = "${c.red}" })
          hi("@keyword.import",       { fg = "${c.red}" })
          hi("@operator",             { fg = "${c.subtle}" })
          hi("@punctuation.bracket",  { fg = "${c.subtle}" })
          hi("@punctuation.delimiter",{ fg = "${c.subtle}" })
          hi("@type",                 { fg = "${c.orange}" })
          hi("@type.builtin",         { fg = "${c.orange}" })
          hi("@tag",                  { fg = "${c.red}" })
          hi("@tag.attribute",        { fg = "${c.orange}" })
          hi("@tag.delimiter",        { fg = "${c.subtle}" })
          hi("@property",             { fg = "${c.text}" })
          hi("@comment",              { fg = "${c.muted}", italic = true })

          -- Diagnostics
          hi("DiagnosticError",         { fg = "${c.red}" })
          hi("DiagnosticWarn",          { fg = "${c.orange}" })
          hi("DiagnosticInfo",          { fg = "${c.subtle}" })
          hi("DiagnosticHint",          { fg = "${c.muted}" })
          hi("DiagnosticUnderlineError",{ undercurl = true, sp = "${c.red}" })
          hi("DiagnosticUnderlineWarn", { undercurl = true, sp = "${c.orange}" })
          hi("DiagnosticUnderlineInfo", { undercurl = true, sp = "${c.subtle}" })
          hi("DiagnosticUnderlineHint", { undercurl = true, sp = "${c.muted}" })

          -- Telescope
          hi("TelescopeNormal",        { fg = "${c.text}", bg = "${c.overlay}" })
          hi("TelescopeBorder",        { fg = "${c.muted}", bg = "${c.overlay}" })
          hi("TelescopePromptNormal",  { fg = "${c.text}", bg = "${c.surface}" })
          hi("TelescopePromptBorder",  { fg = "${c.muted}", bg = "${c.surface}" })
          hi("TelescopePromptTitle",   { fg = "${c.base}", bg = "${c.orange}", bold = true })
          hi("TelescopePreviewTitle",  { fg = "${c.base}", bg = "${c.red}", bold = true })
          hi("TelescopeResultsTitle",  { fg = "${c.base}", bg = "${c.red}", bold = true })
          hi("TelescopeSelection",     { bg = "${c.highlightMed}" })
          hi("TelescopeMatching",      { fg = "${c.orange}", bold = true })
        '';
      };
    };
  };
}
