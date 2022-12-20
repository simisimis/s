{
  description = "Sims' nix config root flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-22.11";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-22.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    ipu6-drivers.url = "github:Mitame/ipu6-nix";
    ipu6-drivers.inputs.nixpkgs.follows = "nixpkgs-unstable";

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
      inherit pkgs;
      modules = [
        { _module.args = args; }
        ./hosts/${host}/home.nix
        ./hm/base.nix
        ./hm/${type}.nix
        ./modules/settings.nix
        {
          home = {
            username = user;
            homeDirectory = "/home/${user}";
            stateVersion = "22.11";
          };
        }
      ];
    };
  in {
    homeConfigurations = {
      gnosis = mkHome "snarbutas" "gnosis" "workstation";
      lavirinthos = mkHome "simonas" "lavirinthos" "workstation";
      siMONSTER = mkHome "simas" "siMONSTER" "workstation";
      backute = mkHome "simas" "backute" "headless";
    };
    gnosis = self.homeConfigurations.gnosis.activationPackage;
    nixosConfigurations = {
      gnosis = mkHost "gnosis";
      backute = mkHost "backute";
      siMONSTER = mkHost "siMONSTER";
      lavirinthos = mkHost "lavirinthos";
    }; #nixosConfigurations
    devShell.x86_64-linux = pkgs.mkShell {
      buildInputs = with pkgs; [
        stdenv
        openssl
        pkg-config
      ];
    }; # devShell
  }; #outputs
}
