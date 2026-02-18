{ colorscheme, lib, pkgs, ... }:

let
  c = colorscheme;
  inherit (lib.generators) mkLuaInline;
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

        autocomplete = {
          blink-cmp.enable = false;

          nvim-cmp = {
            enable = true;
            mappings = {
              complete = "<C-Space>";
              confirm = "<CR>";
              next = "<Tab>";
              previous = "<S-Tab>";
              close = "<C-e>";
              scrollDocsUp = "<C-d>";
              scrollDocsDown = "<C-f>";
            };
          };
        };

        snippets.luasnip.enable = true;
        autopairs.nvim-autopairs.enable = true;

        formatter.conform-nvim = {
          enable = true;
          setupOpts = {
            format_on_save = null;

            formatters = {
              alejandra.command = "${pkgs.alejandra}/bin/alejandra";
              biome.command = "${pkgs.biome}/bin/biome";
              ruff_format.command = "${pkgs.ruff}/bin/ruff";
              gofumpt.command = "${pkgs.gofumpt}/bin/gofumpt";
              stylua.command = "${pkgs.stylua}/bin/stylua";
              rustfmt.command = "${pkgs.rustfmt}/bin/rustfmt";
              "clang-format".command = "${pkgs.clang-tools}/bin/clang-format";
              "google-java-format".command = "${pkgs.google-java-format}/bin/google-java-format";
              csharpier.command = "${pkgs.csharpier}/bin/csharpier";
            };

            formatters_by_ft = {
              nix = [ "alejandra" ];

              javascript = [ "biome" ];
              javascriptreact = [ "biome" ];
              typescript = [ "biome" ];
              typescriptreact = [ "biome" ];
              html = [ "biome" ];
              css = [ "biome" ];
              scss = [ "biome" ];
              less = [ "biome" ];

              python = [ "ruff_format" ];
              go = [ "gofumpt" ];
              lua = [ "stylua" ];
              rust = [ "rustfmt" ];

              c = [ "clang-format" ];
              cpp = [ "clang-format" ];
              java = [ "google-java-format" ];
              cs = [ "csharpier" ];
            };
          };
        };

        augroups = [
          {
            name = "nvf_nvim_lint_open";
          }
        ];

        autocmds = [
          {
            event = [ "BufReadPost" ];
            group = "nvf_nvim_lint_open";
            desc = "Run lint on file open";
            callback = mkLuaInline ''
              function(args)
                if type(nvf_lint) == "function" then
                  nvf_lint(args.buf)
                end
              end
            '';
          }
        ];

        keymaps = [
          {
            key = "<leader>f";
            mode = "n";
            desc = "Format current buffer";
            lua = true;
            action = ''
              function()
                local ok, conform = pcall(require, "conform")
                if ok then
                  conform.format({ async = false, lsp_format = "fallback" })
                  return
                end

                vim.lsp.buf.format({ async = false })
              end
            '';
          }
          {
            key = "<leader>l";
            mode = "n";
            desc = "Lint current buffer";
            lua = true;
            action = ''
              function()
                if type(nvf_lint) == "function" then
                  nvf_lint(vim.api.nvim_get_current_buf())
                  return
                end

                local ok, lint = pcall(require, "lint")
                if ok then
                  lint.try_lint()
                end
              end
            '';
          }
        ];

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
            rust_analyzer = {
              cmd = [ "${pkgs.rust-analyzer}/bin/rust-analyzer" ];
              root_dir = lib.mkForce (mkLuaInline ''
                function(bufnr, on_dir)
                  if vim.fn.executable("cargo") ~= 1 then
                    _G.nvf_missing_lsp_runtime_warnings = _G.nvf_missing_lsp_runtime_warnings or {}
                    if not _G.nvf_missing_lsp_runtime_warnings.rust_analyzer then
                      _G.nvf_missing_lsp_runtime_warnings.rust_analyzer = true
                      vim.notify(
                        "rust-analyzer skipped: 'cargo' executable not found in this environment.",
                        vim.log.levels.WARN
                      )
                    end
                    on_dir(nil)
                    return
                  end

                  local fname = vim.api.nvim_buf_get_name(bufnr)
                  on_dir(vim.fs.root(fname, "Cargo.toml") or vim.fs.root(fname, "rust-project.json"))
                end
              '');
            };

            gopls = {
              root_dir = lib.mkForce (mkLuaInline ''
                function(bufnr, on_dir)
                  if vim.fn.executable("go") ~= 1 then
                    _G.nvf_missing_lsp_runtime_warnings = _G.nvf_missing_lsp_runtime_warnings or {}
                    if not _G.nvf_missing_lsp_runtime_warnings.gopls then
                      _G.nvf_missing_lsp_runtime_warnings.gopls = true
                      vim.notify(
                        "gopls skipped: 'go' executable not found in this environment.",
                        vim.log.levels.WARN
                      )
                    end
                    on_dir(nil)
                    return
                  end

                  local fname = vim.api.nvim_buf_get_name(bufnr)
                  on_dir(vim.fs.root(fname, "go.work") or vim.fs.root(fname, "go.mod") or vim.fs.root(fname, ".git"))
                end
              '');
            };

            jdtls.enable = lib.mkForce false;
            csharp_ls.enable = lib.mkForce false;
          };
        };

        diagnostics = {
          enable = true;

          nvim-lint = {
            enable = true;
            lint_after_save = true;

            linters_by_ft = {
              nix = [ "statix" "deadnix" ];
              lua = [ "luacheck" ];

              javascript = [ "biomejs" ];
              javascriptreact = [ "biomejs" ];
              typescript = [ "biomejs" ];
              typescriptreact = [ "biomejs" ];
              html = [ "biomejs" ];
              css = [ "biomejs" ];
              scss = [ "biomejs" ];
              less = [ "biomejs" ];

              python = [ "ruff" ];
              rust = [ "clippy" ];
              go = [ "golangcilint" ];
              c = [ "cppcheck" ];
              cpp = [ "cppcheck" ];
              java = [ "checkstyle" ];
            };

            linters.checkstyle.args = [ "-f" "sarif" "-c" "/google_checks.xml" ];
            linters.statix.cmd = "${pkgs.statix}/bin/statix";
            linters.deadnix.cmd = "${pkgs.deadnix}/bin/deadnix";
            linters.luacheck.cmd = "${pkgs.luajitPackages.luacheck}/bin/luacheck";
            linters.biomejs.cmd = "${pkgs.biome}/bin/biome";
            linters.ruff.cmd = "${pkgs.ruff}/bin/ruff";
            linters.clippy.cmd = "${pkgs.cargo}/bin/cargo";
            linters.clippy.ignore_exitcode = true;
            linters.golangcilint.cmd = "${pkgs.golangci-lint}/bin/golangci-lint";
            linters.cppcheck.cmd = "${pkgs.cppcheck}/bin/cppcheck";
            linters.checkstyle.cmd = "${pkgs.checkstyle}/bin/checkstyle";

            lint_function = mkLuaInline ''
              function(buf)
                local lint = require("lint")
                local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
                local linters = lint.linters
                local linters_from_ft = lint.linters_by_ft[ft]

                if linters_from_ft == nil then
                  return
                end

                if type(linters_from_ft) == "string" then
                  linters_from_ft = { linters_from_ft }
                end

                _G.nvf_missing_linter_warnings = _G.nvf_missing_linter_warnings or {}

                local function warn_missing_once(name, cmd)
                  if _G.nvf_missing_linter_warnings[name] then
                    return
                  end
                  _G.nvf_missing_linter_warnings[name] = true
                  vim.notify(
                    string.format("Skipping linter '%s': executable '%s' not found.", name, cmd),
                    vim.log.levels.WARN
                  )
                end

                local function resolve_cmd(linter)
                  local cmd = linter.cmd

                  if type(cmd) == "function" then
                    local ok, resolved = pcall(cmd)
                    if not ok then
                      return nil
                    end
                    cmd = resolved
                  end

                  if type(cmd) == "table" then
                    return cmd[1]
                  end

                  if type(cmd) == "string" then
                    return cmd
                  end

                  return nil
                end

                for _, name in ipairs(linters_from_ft) do
                  local linter = linters[name]
                  assert(linter, "Linter with name `" .. name .. "` not available")

                  if type(linter) == "function" then
                    linter = linter()
                  end

                  linter.name = linter.name or name

                  local skip_linter = false
                  if name == "clippy" then
                    local fname = vim.api.nvim_buf_get_name(buf)
                    local cargo_root = vim.fs.root(fname, "Cargo.toml")
                    if not cargo_root then
                      warn_missing_once(name, "Cargo.toml (project root)")
                      skip_linter = true
                    else
                      linter.cwd = cargo_root
                    end
                  end

                  if not skip_linter then
                    local cmd = resolve_cmd(linter)
                    if cmd and vim.fn.executable(cmd) ~= 1 then
                      warn_missing_once(name, cmd)
                    else
                      lint.lint(linter)
                    end
                  end
                end
              end
            '';
          };

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
          rust = {
            enable = true;
            lsp.enable = false;
          };
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
          hi("DiffAdd",       { fg = "${c.greenDim}", bg = "${c.highlightLow}" })
          hi("DiffChange",    { fg = "${c.orange}", bg = "${c.highlightLow}" })
          hi("DiffDelete",    { fg = "${c.red}", bg = "${c.highlightLow}" })
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
