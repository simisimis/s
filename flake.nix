{
  description = "Sims' nix config root flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-21.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-21.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.inputs.nixpkgs-unstable.follows = "nixpkgs-unstable";
    binfiles = {
      url = "git+ssh://git@git.narbuto.lt:2203/simas/binfiles?ref=master";
      flake = false;
    }; #binfiles
    zshdfiles = {
      url = "git+ssh://git@git.narbuto.lt:2203/simas/zshd?ref=master";
      flake = false;
    };
  };

 outputs = { self, ... }@inputs:
  let
    system = "x86_64-linux";

    pkgs = import inputs.nixpkgs {
      inherit system;
      config = { allowUnfree = true; };
    };
    unstable = import inputs.nixpkgs-unstable {
      inherit system;
      config = { allowUnfree = true; };
    };
    lib = inputs.nixpkgs.lib;
    args = inputs;
  in {
    homeConfigurations = {
      stateVersion = "21.05";
      snarbutas = inputs.home-manager.lib.homeManagerConfiguration {
        inherit system pkgs;
        username = "snarbutas";
        homeDirectory = "/home/snarbutas";
        configuration = {
          _module = { inherit args; };
          imports = [
            ./hosts/gnosis/home.nix
            ./hm/base.nix
            ./hm/workstation.nix
            ./modules/settings.nix
          ];
        };
      };
      backute = inputs.home-manager.lib.homeManagerConfiguration {
        inherit system pkgs;
        username = "simas";
        homeDirectory = "/home/simas";
        configuration = {
          _module = { inherit args; };
          imports = [
            ./hosts/backute/home.nix
            ./hm/base.nix
            ./modules/settings.nix
          ];
        };
      };
    };
    snarbutas = self.homeConfigurations.snarbutas.activationPackage;
    nixosConfigurations = {
      gnosis = lib.nixosSystem {
        inherit system;
        modules = [
          ./hosts/gnosis/configuration.nix
        ];
      };
      backute = lib.nixosSystem {
        inherit system;
        modules = [
          ./hosts/backute/configuration.nix
        ];
      };
    }; #nixosConfigurations
  }; #outputs
}
