{ pkgs, ... }:

let
	# Keep these aligned with `config/foot.nix` / `config/quickshell/theme/Colors.qml`
	palette = {
		background = "#34363a";
		foreground = "#efeae4";

		panelBg = "#26272a";
		panelBg2 = "#1f2022";
		panelBorder = "#505257";
		muted = "#b9b4ae";
		outline = "#0b0b0c";

		red = "#c24f4f";
		orange = "#d17936";
		highlight = "#cf5b5b";
		green = "#a8ff00";
		dim = "#7a7c80";
	};

in
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
			base16-colors = {
				base00 = palette.background;
				base01 = palette.panelBg;
				base02 = palette.panelBg2;
				base03 = palette.dim;
				base04 = palette.muted;
				base05 = palette.foreground;
				base06 = palette.foreground;
				base07 = palette.foreground;

				base08 = palette.red;
				base09 = palette.orange;
				base0A = palette.highlight;
				base0B = palette.green;
				base0C = palette.orange;
				base0D = palette.orange;
				base0E = palette.red;
				base0F = palette.outline;
			};
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
