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
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    theme = import ./theme.nix;
    customNvf = nvf.lib.mkNeovim { inherit theme; };

    mkSystem = host: nixpkgs.lib.nixosSystem {
      modules = [
        { nixpkgs.hostPlatform = system; }
        ./hosts/${host}/default.nix 
        home-manager.nixosModules.home-manager
        {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit nvf mandrid theme customNvf; };
            home-manager.users.barthmalemew = import ./home.nix;
        }
      ];
    };
  in
  {
    nixosConfigurations = {
      ladmin = mkSystem "ladmin";
      ladmin-laptop = mkSystem "ladmin-laptop";
    };
  };
}
