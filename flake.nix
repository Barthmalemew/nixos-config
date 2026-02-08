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
    pkgs = nixpkgs.legacyPackages.${system};
    
    # We still import the old theme.nix temporarily to pass to NVF until we refactor NVF too.
    # But for the system modules, we will use the new module system.
    legacyTheme = import ./theme.nix;
    customNvf = nvf.lib.mkNeovim { theme = legacyTheme; };

    mkSystem = host: nixpkgs.lib.nixosSystem {
      modules = [
        { nixpkgs.hostPlatform = system; }
        ./hosts/${host}/default.nix 
        home-manager.nixosModules.home-manager
        {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            # We still pass customNvf, but 'theme' is now a module, not a special arg!
            home-manager.extraSpecialArgs = { inherit nvf mandrid customNvf; };
            home-manager.users.barthmalemew = {
              imports = [ 
                ./home.nix 
                ./modules/theme.nix # Import our new theme module here!
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
