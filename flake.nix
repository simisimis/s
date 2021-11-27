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
    args = inputs;

    mkHost = host: inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        { _module.args = args; }
        ./hosts/${host}/configuration.nix
      ];
    };
    mkHome = user: host: type: inputs.home-manager.lib.homeManagerConfiguration {
      inherit system pkgs;
      username = user;
      homeDirectory = "/home/${user}";
      configuration = {
        _module = { inherit args; };
        imports = [
          ./hosts/${host}/home.nix
          ./hm/base.nix
          ./hm/${type}.nix
          ./modules/settings.nix
        ];
      };
    };
  in {
    homeConfigurations = {
      stateVersion = "21.05";
      gnosis = mkHome "snarbutas" "gnosis" "workstation";
      backute = mkHome "simas" "backute" "headless";
    };
    gnosis = self.homeConfigurations.gnosis.activationPackage;
    nixosConfigurations = {
      gnosis = mkHost "gnosis";
      backute = mkHost "backute";
    }; #nixosConfigurations
  }; #outputs
}
