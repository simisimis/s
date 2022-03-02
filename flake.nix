{
  description = "Sims' nix config root flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-21.11";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-21.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.inputs.nixpkgs-unstable.follows = "nixpkgs-unstable";
    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    binfiles = {
      url = "git+ssh://git@git.narbuto.lt:2203/simas/binfiles?ref=master";
      flake = false;
    }; #binfiles
    zshdfiles = {
      url = "git+ssh://git@git.narbuto.lt:2203/simas/zshd?ref=master";
      flake = false;
    };
    awesomewm = {
      url = "git+ssh://git@git.narbuto.lt:2203/simas/awesome?ref=master";
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
        inputs.agenix.nixosModule
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
      stateVersion = "21.11";
      gnosis = mkHome "snarbutas" "gnosis" "workstation";
      siMONSTER = mkHome "simas" "siMONSTER" "workstation";
      backute = mkHome "simas" "backute" "headless";
    };
    gnosis = self.homeConfigurations.gnosis.activationPackage;
    nixosConfigurations = {
      gnosis = mkHost "gnosis";
      backute = mkHost "backute";
      siMONSTER = mkHost "siMONSTER";
    }; #nixosConfigurations
  }; #outputs
}
