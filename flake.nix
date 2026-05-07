{
  description = "Sims' nix config root flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.systems.follows = "flake-utils/systems";
    };
    rtk-nix = {
      url = "github:hypervideo/rtk-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

  };

  outputs = { self, flake-utils, llm-agents, ... }@inputs:
    let
      system = "x86_64-linux";

      nixpkgsConfig = {
        allowUnfree = true;
        android_sdk.accept_license = true;
      };
      pkgs = import inputs.nixpkgs {
        inherit system;
        config = nixpkgsConfig;
      };
      unstable = import inputs.nixpkgs-unstable {
        inherit system;
        config = nixpkgsConfig;
      };
      args = inputs;

      mkHost = host:
        inputs.nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            { _module.args = args // { inherit llm-agents unstable; }; }
            inputs.disko.nixosModules.disko
            ./hosts/${host}/configuration.nix
          ];
        };
      mkHome = user: host: type:
        inputs.home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            { _module.args = args // { inherit llm-agents unstable; }; }
            ./hosts/${host}/home.nix
            ./hm/base.nix
            ./hm/${type}.nix
            ./modules/settings.nix
            {
              home = {
                username = user;
                homeDirectory = "/home/${user}";
                stateVersion = "25.11";
              };
            }
          ];
        };
      mkBaseEnv = pkgs:
        pkgs.buildEnv {
          name = "common-docker-env";

          paths = [
            pkgs.bashInteractive
            pkgs.cacert
            pkgs.openssl
            pkgs.tzdata
            pkgs.glibcLocales
            pkgs.coreutils
            pkgs.findutils
            pkgs.procps
            pkgs.dockerTools.shadowSetup
            pkgs.shadow
            pkgs.which

            pkgs.curl
            pkgs.jq
            pkgs.gnutar
            pkgs.gzip
            pkgs.lz4
            pkgs.neovim
          ];
          pathsToLink = [ "/bin" "/etc" "/share" ];
        };
    in flake-utils.lib.eachSystemPassThrough [ system ] (_: {
      homeConfigurations = {
        icarus = mkHome "simonas" "icarus" "workstation";
        lavirinthos = mkHome "simonas" "lavirinthos" "workstation";
        siMONSTER = mkHome "simas" "siMONSTER" "workstation";
        kouti = mkHome "simas" "kouti" "headless";
        clotho = mkHome "simas" "clotho" "headless";
        lachesis = mkHome "simas" "lachesis" "headless";
        devops = mkHome "simonas" "devops" "headless";
      };
      nixosConfigurations = {
        siMONSTER = mkHost "siMONSTER";
        icarus = mkHost "icarus";
        lavirinthos = mkHost "lavirinthos";
        kouti = mkHost "kouti";
        clotho = mkHost "clotho";
        lachesis = mkHost "lachesis";
      }; # nixosConfigurations
      templates = {
        rust = {
          path = ./templates/rust;
          description = "Rust template, using buildRustPackage";
        };
      };
      defaultTemplate = self.templates.rust;
    }) // flake-utils.lib.eachSystem [ system ] (_: {
      packages.radicle-node = pkgs.dockerTools.buildLayeredImage {
        name = "simisimis/radicle-node";
        tag = "latest";
        contents = [ pkgs.radicle-node (mkBaseEnv pkgs) ];

        config = {
          #Entrypoint = [ "${pkgs.radicle-node}/bin/radicle-node" ];
          Entrypoint = [ "${pkgs.bashInteractive}/bin/bash" ];
          Env = [
            "TZ=UTC"
            "TZDIR=${pkgs.tzdata}/share/zoneinfo"
            "SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt"

            "RAD_HOME=/data/.radicle"
          ];
          #Cmd = [ "-p" "1925" ];
          WorkingDir = "/data";
        };
      };

      devShells.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          nmap
          stdenv
          openssl
          pkg-config
          nodejs_24
          #postgresql_16
          #cmake
          #ninja
          #(python312.withPackages (ps: with ps; [ pyserial west pyelftools intelhex termcolor crcmod requests ruamel-yaml pip yamllint flake8 setuptools shapely ]))
        ];
        shellHook = ''
          user_shell=$(getent passwd "$(whoami)" |cut -d: -f 7)
          exec "$user_shell"
        '';
      };
    }); # outputs
}
