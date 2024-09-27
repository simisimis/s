{
  description = "Sims' nix config root flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    binfiles = {
      url = "git+ssh://git@backute:2203/simas/binfiles?ref=master";
      flake = false;
    }; #binfiles
    # ipu6-softisp = {
    #   url = "git+ssh://code.tvl.fyi/depot.git:/users/flokli/ipu6-softisp.git";
    #   flake = false;
    # }; #ipu6-softisp
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
              stateVersion = "24.05";
            };
          }
        ];
      };
    in
    {
      homeConfigurations = {
        gnosis = mkHome "snarbutas" "gnosis" "workstation";
        lavirinthos = mkHome "simonas" "lavirinthos" "workstation";
        siMONSTER = mkHome "simas" "siMONSTER" "workstation";
        backute = mkHome "simas" "backute" "headless";
        polyphemus = mkHome "simas" "polyphemus" "headless";
        kouti = mkHome "simas" "kouti" "headless";
      };
      gnosis = self.homeConfigurations.gnosis.activationPackage;
      nixosConfigurations = {
        gnosis = mkHost "gnosis";
        backute = mkHost "backute";
        siMONSTER = mkHost "siMONSTER";
        lavirinthos = mkHost "lavirinthos";
        polyphemus = mkHost "polyphemus";
        kouti = mkHost "kouti";
      }; #nixosConfigurations
      devShell.x86_64-linux = pkgs.mkShell {
        buildInputs = with pkgs; [
          nmap
          stdenv
          openssl
          pkg-config
          nodejs_20
        ];
        shellHook = ''
          user_shell=$(getent passwd "$(whoami)" |cut -d: -f 7)
          exec "$user_shell"
        '';

      }; # devShell

      templates = {
        rust = {
          path = ./templates/rust;
          description = "Rust template, using buildRustPackage";
        };
      };
      defaultTemplate = self.templates.rust;
    }; #outputs
}
