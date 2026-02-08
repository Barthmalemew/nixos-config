{
	inputs = { 
		nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
		nvf.url = "github:notashelf/nvf";
        flake-utils.url = "github:numtide/flake-utils";
	};
	
	outputs = { nixpkgs, nvf, flake-utils, ... }: 
    flake-utils.lib.eachDefaultSystem (system:
    let
        pkgs = nixpkgs.legacyPackages.${system};
        
        # Default theme for standalone builds
        defaultTheme = {
            colors = {
                background = "#34363a";
                panelBg = "#26272a";
                panelBg2 = "#1f2022";
                dim = "#7a7c80";
                muted = "#b9b4ae";
                foreground = "#efeae4";
                red = "#c24f4f";
                orange = "#d17936";
                highlight = "#cf5b5b";
                green = "#a8ff00";
                outline = "#0b0b0c";
            };
        };

        # Helper to map your theme schema to NVF's base16
        mkBase16 = theme: {
            base00 = theme.colors.background;
            base01 = theme.colors.panelBg;
            base02 = theme.colors.panelBg2;
            base03 = theme.colors.dim;
            base04 = theme.colors.muted;
            base05 = theme.colors.foreground;
            base06 = theme.colors.foreground;
            base07 = theme.colors.foreground;
            base08 = theme.colors.red;
            base09 = theme.colors.orange;
            base0A = theme.colors.highlight;
            base0B = theme.colors.green;
            base0C = theme.colors.orange;
            base0D = theme.colors.orange;
            base0E = theme.colors.red;
            base0F = theme.colors.outline;
        };
        
        # The core builder function
        buildNeovim = { theme ? defaultTheme }: (nvf.lib.neovimConfiguration {
			inherit pkgs;
			modules = [ 
				./nvf-configuration.nix 
				({ ... }: {
					vim.theme.enable = true;
					vim.theme.base16-colors = mkBase16 theme;
				})
			];
		}).neovim;

    in {
		packages.default = buildNeovim { };

        # Exposed library for other flakes to use
		lib.mkNeovim = { theme }: buildNeovim { inherit theme; };
	});
} 
