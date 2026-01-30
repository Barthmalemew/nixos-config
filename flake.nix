{
  description = "Kevin's systems - Main System Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
    	url = "github:nix-community/home-manager";
        inputs.nixpkgs.follows = "nixpkgs";
    };

    nvf.url = "path:./nvf";
    mandrid = {
        url = "github:Barthmalemew/mandrid";
        inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, nvf, mandrid, ... }: 
  let
    theme = import ./theme.nix;
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
    customNvf = nvf.lib.mkNeovim { inherit theme; };
  in
  {
    nixosConfigurations.ladmin-laptop = nixpkgs.lib.nixosSystem {
	modules = [ 
    { nixpkgs.hostPlatform = "x86_64-linux"; }
	./hosts/ladmin-laptop/default.nix 
	home-manager.nixosModules.home-manager
	{
		home-manager.useGlobalPkgs = true;
		home-manager.useUserPackages = true;
		home-manager.extraSpecialArgs = { inherit nvf mandrid theme customNvf; };
		home-manager.users.barthmalemew = import ./home.nix;
	}
      ];
    };
    nixosConfigurations.ladmin = nixpkgs.lib.nixosSystem {
	modules = [ 
    { nixpkgs.hostPlatform = "x86_64-linux"; }
	./hosts/ladmin/default.nix 
	home-manager.nixosModules.home-manager
	{
		home-manager.useGlobalPkgs = true;
		home-manager.useUserPackages = true;
		home-manager.extraSpecialArgs = { inherit nvf mandrid theme customNvf; };
		home-manager.users.barthmalemew = import ./home.nix;
	}
      ];
    };
  };
}
