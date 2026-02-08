{ config, pkgs, ...}:

{
	imports = [
		./modules/home/foot.nix
		./modules/home/opencode.nix
		./modules/home/niri.nix
		./modules/home/apps.nix
		./modules/home/desktop.nix
		./modules/home/services.nix
		./modules/home/git.nix
		./modules/home/quickshell.nix
		./modules/home/ssh.nix
		./modules/home/shell.nix
		./modules/home/gtk-qt.nix
	];

	home.username = "barthmalemew";
	home.homeDirectory = "/home/barthmalemew";
	
	fonts.fontconfig.enable = true;
	
	# Cursor Theme
	home.pointerCursor = {
		package = pkgs.bibata-cursors;
		name = "Bibata-Modern-Classic";
		size = 24;
	};

	# Mandrid pack defaults for OpenCode (ByteRover-like behavior)
	home.sessionVariables = {
		MANDRID_PACK_BUDGET = "400";
		MANDRID_PACK_EPISODIC = "1";
		MANDRID_PACK_TYPE_CAPS = "trace=2,thought=1,task=2,auto=2,interaction=1";
		MANDRID_PACK_TRIM_HISTORY = "1";
	};

	home.stateVersion = "24.11";


}
