{
	inputs = { 
		nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
		nvf.url = "github:notashelf/nvf";
	};
	
	outputs = { nixpkgs, nvf, ... }: {
		packages.x86_64-linux.default = (nvf.lib.neovimConfiguration {
			pkgs = nixpkgs.legacyPackages.x86_64-linux;
			modules = [ ./nvf-configuration.nix ];
		}).neovim;

		# Add a way to override the configuration with a theme
		lib.mkNeovim = { theme }: (nvf.lib.neovimConfiguration {
			pkgs = nixpkgs.legacyPackages.x86_64-linux;
			modules = [ 
				./nvf-configuration.nix 
				({ ... }: {
					vim.theme.enable = true;
					vim.theme.base16-colors = {
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
				})
			];
		}).neovim;
	};
} 
