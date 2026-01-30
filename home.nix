{ config, pkgs, nvf, mandrid, theme, customNvf, ...}:

{
	imports = [
		./config/foot.nix
		./config/opencode.nix
	];

	home.username = "barthmalemew";
	home.homeDirectory = "/home/barthmalemew";
	
	home.packages = with pkgs; [
		fastfetch
		git
                python3
		gemini-cli
                codex
                rembg
		opencode
		vivaldi
		customNvf
		mandrid.packages.${pkgs.system}.default
		bibata-cursors
		swaybg
                quickshell
		grim
		slurp
		wl-clipboard
		obsidian
	];

	fonts.fontconfig.enable = true;
	
	programs.git = {
		enable = true;
        settings = {
            user = {
                name = "barthmalemew";
                email = "kevinrouse105@gmail.com";
            };
        };
	};

	programs.ssh = {
		enable = true;
		matchBlocks = {
			"*" = {
				addKeysToAgent = "yes";
			};
			"github.com" = {
				user = "git";
				identityFile = "~/.ssh/id_ed25519";
				identitiesOnly = true;
			};
		};
	};

	# Start an ssh-agent on login (systemd user service).
	services.ssh-agent.enable = true;

	# Auto-load the GitHub key into the agent.
	# (Works best with an unencrypted key; otherwise needs an askpass.)
	systemd.user.services.ssh-add-github = {
		Unit = {
			Description = "Load GitHub SSH key";
			After = [ "ssh-agent.service" "graphical-session.target" ];
			PartOf = [ "graphical-session.target" ];
		};
		Service = {
			Type = "oneshot";
			Environment = [ "SSH_AUTH_SOCK=%t/ssh-agent" ];
			ExecStart = "${pkgs.bash}/bin/sh -lc '${pkgs.openssh}/bin/ssh-add /home/barthmalemew/.ssh/id_ed25519 || true'";
		};
		Install = {
			WantedBy = [ "graphical-session.target" ];
		};
	};

	# Cursor Theme
	home.pointerCursor = {
		gtk.enable = true;
		package = pkgs.bibata-cursors;
		name = "Bibata-Modern-Classic";
		size = 24;
	};

	# Config Links
	home.file.".config/niri/config.kdl".text = 
        let 
            baseConfig = builtins.readFile ./config/niri/config.kdl;
        in
        builtins.replaceStrings [ "\"#c24f4f\"" ] [ "\"${theme.colors.red}\"" ] baseConfig;

    home.file.".config/quickshell".source = ./config/quickshell;
	home.file.".config/quickshell/theme/Colors.qml".text = ''
		import QtQuick

		QtObject {
			readonly property string background: "${theme.colors.background}"
			readonly property string foreground: "${theme.colors.foreground}"
			readonly property string cursor: "${theme.colors.cursor}"

			readonly property string panelBg: "${theme.colors.panelBg}"
			readonly property string panelBg2: "${theme.colors.panelBg2}"
			readonly property string panelBorder: "${theme.colors.panelBorder}"
			readonly property string muted: "${theme.colors.muted}"
			readonly property string outline: "${theme.colors.outline}"

			readonly property string clockHour: "${theme.colors.red}"
			readonly property string clockMinute: "${theme.colors.red}"
			readonly property string clock: "${theme.colors.red}"

			readonly property string color0: "${theme.colors.panelBg}"
			readonly property string color1: "${theme.colors.red}"
			readonly property string color2: "${theme.colors.orange}"
			readonly property string color3: "${theme.colors.darkRed}"
			readonly property string color4: "${theme.colors.green}"
			readonly property string color5: "${theme.colors.highlight}"
			readonly property string color6: "${theme.colors.orange}"
			readonly property string color7: "${theme.colors.foreground}"
			readonly property string color8: "${theme.colors.dim}"
			readonly property string color9: "${theme.colors.highlight}"
			readonly property string color10: "${theme.colors.orange}"
			readonly property string color11: "${theme.colors.orange}"
			readonly property string color12: "${theme.colors.red}"
			readonly property string color13: "${theme.colors.orange}"
			readonly property string color14: "${theme.colors.foreground}"
			readonly property string color15: "${theme.colors.foreground}"

			readonly property string black: "#000000"
			readonly property string red: color1
			readonly property string green: color4
			readonly property string yellow: color5
			readonly property string blue: color4
			readonly property string magenta: color5
			readonly property string cyan: color6
			readonly property string white: foreground

			readonly property string brightBlack: color8
			readonly property string brightRed: color1
			readonly property string brightGreen: color4
			readonly property string brightYellow: color11
			readonly property string brightBlue: color12
			readonly property string brightMagenta: color5
			readonly property string brightCyan: color6
			readonly property string brightWhite: foreground
		}
	'';

	home.stateVersion = "25.11";
	programs.home-manager.enable = true;

	systemd.user.services.polkit-kde-agent = {
		Unit = {
			Description = "Polkit KDE Authentication Agent";
			After = [ "graphical-session.target" ];
			PartOf = [ "graphical-session.target" ];
		};
		Service = {
			ExecStart = "${pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1";
			Restart = "on-failure";
		};
		Install = {
			WantedBy = [ "graphical-session.target" ];
		};
	};
}
