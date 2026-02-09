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
    };
  };

  outputs = { nixpkgs, home-manager, nvf, mandrid, ... }: 
  let
    system = "x86_64-linux";

    mkSystem = host: nixpkgs.lib.nixosSystem {
      modules = [
        ./hosts/${host}/default.nix 
        ./modules/theme.nix
        home-manager.nixosModules.home-manager
        {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit nvf mandrid; };
            home-manager.users.barthmalemew = {
              imports = [
                ./home.nix
              ];
            };
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
