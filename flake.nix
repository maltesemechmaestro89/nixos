{
  description = "Hyprland on Nixos";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    caelestia-shell = {
      url = "github:caelestia-dots/shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ...}@inputs: {
    nixosConfigurations.hyprland = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
	./configuration.nix
	home-manager.nixosModules.home-manager
	{
	  home-manager = {
	    useGlobalPkgs = true;
	    useUserPackages = true;
	    extraSpecialArgs = { inherit inputs; };
	    users.schuyler = import ./home.nix;
	    backupFileExtension = "backup";
	  };
	}
      ];
    };
  };
}
