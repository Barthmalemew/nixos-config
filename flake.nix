{
  description = "barthmalemew's NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri.url = "github:sodiboo/niri-flake";

    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, niri, nvf, ... }@inputs: 
    let
      system = "x86_64-linux";            
      username = "barthmalemew";          
      
      mkHost = host: nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs username; };
        modules = [
          ./hosts/${host}/default.nix
          niri.nixosModules.niri
          home-manager.nixosModules.home-manager
          {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit username; };
          home-manager.users.${username} = import ./home/default.nix;
          home-manager.sharedModules = [ inputs.nvf.homeManagerModules.default ];
        }
        ];
      };    
    in
    {
      nixosConfigurations = {
        ladmin = mkHost "ladmin";
        ladmin-laptop = mkHost "ladmin-laptop";
      };
    };
}
