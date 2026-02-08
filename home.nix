{ config, pkgs, nvf, mandrid, customNvf, ...}:

let 
  # Shorthand to access the theme config we defined in modules/theme.nix
  theme = config.theme.colors;
  
  cursor = {
    name = "Bibata-Modern-Classic";
    package = pkgs.bibata-cursors;
    size = 24;
  };
in
{
	imports = [
		./config/foot.nix
		./config/opencode.nix
		./config/niri/config.nix
	];

	home.username = "barthmalemew";
	home.homeDirectory = "/home/barthmalemew";
	
	home.packages = with pkgs; [
		# Terminal & Shell
		fastfetch
		git
		python3
		gemini-cli
		opencode
		mandrid.packages.${pkgs.system}.default
		
		# Editors & Tools
		customNvf
		obsidian
		
		# Multimedia & Graphics
		rembg
		codex
		grim
		slurp
		wl-clipboard
		
		# Web
		vivaldi
		
		# Desktop Environment
		quickshell
		swaybg
		bibata-cursors
		
		# Migrated from configuration.nix
		foot
		wofi
		yazi
		swaylock
		kdePackages.dolphin
	];

	fonts.fontconfig.enable = true;
	
	programs.git = {
		enable = true;
		
		# Better diffs with syntax highlighting
		delta = {
			enable = true;
			options = {
				navigate = true;    # usage of n and N to move between diff sections
				line-numbers = true;
			};
		};

        settings = {
            user = {
                name = "barthmalemew";
                email = "kevinrouse105@gmail.com";
            };
            
            # Modern defaults
            init.defaultBranch = "main";
            pull.rebase = true;
            push.autoSetupRemote = true;
        };
	};

	programs.ssh = {
		enable = true;
		enableDefaultConfig = false;
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

	# Shell Aliases for NixOS Maintenance
	home.shellAliases = {
		# Rebuild the system using the flake in the current directory
		rebuild = "sudo nixos-rebuild switch --flake .";
		
		# Update flake inputs
		upd = "nix flake update";
		
		# Garbage collection (delete old generations)
		clean = "nix-collect-garbage -d";
		
		# Quick navigation
		conf = "cd ~/nixos-config";
	};

	# Cursor Theme
	home.pointerCursor = {
		gtk.enable = true;
		x11.enable = true;
		inherit (cursor) name package size;
	};
	
	home.sessionVariables = {
		XCURSOR_THEME = cursor.name;
		XCURSOR_SIZE = toString cursor.size;
	};

    # GTK Theme (KDE Breeze Style)
    gtk = {
        enable = true;
        theme = {
            name = "Breeze";
            package = pkgs.kdePackages.breeze-gtk;
        };
        iconTheme = {
            name = "breeze-dark";
            package = pkgs.kdePackages.breeze-icons;
        };
    };
    
    # Configure Swaylock to match theme
    programs.swaylock = {
        enable = true;
        settings = {
            image = "${./assets/wallpapers/unit2.png}";
            scaling = "fill";
            color = "${theme.background}";
            
            # Ring Colors (Matches Theme)
            inside-color = "${theme.background}99"; # transparent background
            ring-color = "${theme.panelBorder}";
            line-color = "${theme.background}";
            key-hl-color = "${theme.highlight}";
            separator-color = "${theme.background}";
            
            # Text Colors
            text-color = "${theme.foreground}";
            text-caps-lock-color = "${theme.red}";
            
            daemonize = true;
        };
    };

    # Idle & Lock Management
    services.swayidle = {
        enable = true;
        timeouts = [
            # Lock after 10 minutes
            { timeout = 600; command = "${pkgs.swaylock}/bin/swaylock -f"; }
            # Turn off screens after 15 minutes (if locked)
            { timeout = 900; command = "${pkgs.niri}/bin/niri msg action power-off-monitors"; resumeCommand = "${pkgs.niri}/bin/niri msg action power-on-monitors"; }
        ];
        events = [
            { event = "before-sleep"; command = "${pkgs.swaylock}/bin/swaylock -f"; }
            { event = "lock"; command = "${pkgs.swaylock}/bin/swaylock -f"; }
        ];
    };

	xdg.configFile."quickshell" = {
		source = ./config/quickshell;
		recursive = true;
	};
	xdg.configFile."quickshell/theme/Colors.qml".text = ''
		import QtQuick

		QtObject {
			readonly property string background: "${theme.background}"
			readonly property string foreground: "${theme.foreground}"
			readonly property string cursor: "${theme.cursor}"

			readonly property string panelBg: "${theme.panelBg}"
			readonly property string panelBg2: "${theme.panelBg2}"
			readonly property string panelBorder: "${theme.panelBorder}"
			readonly property string muted: "${theme.muted}"
			readonly property string outline: "${theme.outline}"

			readonly property string clockHour: "${theme.red}"
			readonly property string clockMinute: "${theme.red}"
			readonly property string clock: "${theme.red}"

			readonly property string color0: "${theme.panelBg}"
			readonly property string color1: "${theme.red}"
			readonly property string color2: "${theme.orange}"
			readonly property string color3: "${theme.darkRed}"
			readonly property string color4: "${theme.green}"
			readonly property string color5: "${theme.highlight}"
			readonly property string color6: "${theme.orange}"
			readonly property string color7: "${theme.foreground}"
			readonly property string color8: "${theme.dim}"
			readonly property string color9: "${theme.highlight}"
			readonly property string color10: "${theme.orange}"
			readonly property string color11: "${theme.orange}"
			readonly property string color12: "${theme.red}"
			readonly property string color13: "${theme.orange}"
			readonly property string color14: "${theme.foreground}"
			readonly property string color15: "${theme.foreground}"

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

	home.stateVersion = "24.11";


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

	systemd.user.services.quickshell = {
		Unit = {
			Description = "QuickShell Desktop Shell";
			After = [ "graphical-session.target" ];
			PartOf = [ "graphical-session.target" ];
		};
		Service = {
			ExecStart = "${pkgs.quickshell}/bin/qs";
			Restart = "always";
			RestartSec = 2;
		};
		Install = {
			WantedBy = [ "graphical-session.target" ];
		};
	};

	systemd.user.services.swaybg = {
		Unit = {
			Description = "Swaybg Wallpaper Service";
			After = [ "graphical-session.target" ];
			PartOf = [ "graphical-session.target" ];
		};
		Service = {
			# Run on all monitors to ensure the vertical monitor gets the wallpaper.
			# QuickShell will overlay the robot mask on the main monitor only.
			ExecStart = "${pkgs.swaybg}/bin/swaybg -m fill -i ${./assets/wallpapers/unit2.png}";
			Restart = "always";
		};
		Install = {
			WantedBy = [ "graphical-session.target" ];
		};
	};
}
