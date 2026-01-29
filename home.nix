{ config, pkgs, nvf, mandrid, ...}:

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
		nvf.packages.${pkgs.system}.default
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
	home.file.".config/niri".source = ./config/niri;
        home.file.".config/quickshell".source = ./config/quickshell;

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
