{
  description = "Sims' nix config root flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    flake-utils.url = "github:numtide/flake-utils";
    jj-starship.url = "github:dmmulroy/jj-starship";
    jj-starship.inputs.nixpkgs.follows = "nixpkgs-unstable";
    jj-starship.inputs.flake-utils.follows = "flake-utils";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    zen-browser.url = "github:youwen5/zen-browser-flake";
    zen-browser.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { self, flake-utils, ... }@inputs:
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
      lib = inputs.nixpkgs.lib;
      args = inputs;

      # Hosts are discovered from hosts/<name>/. A host gets a NixOS config when
      # it has configuration.nix and a Home Manager config when it has home.nix.
      hostDirs = lib.attrNames (
        lib.filterAttrs (_: type: type == "directory") (builtins.readDir ./hosts)
      );
      hostsWith = file: builtins.filter (host: builtins.pathExists ./hosts/${host}/${file}) hostDirs;
      hostRole = host: (import ./hosts/${host}/vars.nix).hw.role or "headless";

      # Wiring shared by every NixOS host: layers, vars, overlays, identity.
      mkHost =
        hostname:
        lib.nixosSystem {
          inherit system;
          modules = [
            {
              _module.args = args // {
                inherit unstable hostname;
              };
            }
            inputs.disko.nixosModules.disko
            ./nixos/base.nix
            ./nixos/${hostRole hostname}.nix
            ./modules/vars-schema.nix
            ./hosts/${hostname}/configuration.nix
            (
              { config, ... }:
              {
                settings = import ./hosts/${hostname}/vars.nix;
                nixpkgs.overlays = [ (import ./overlays) ];
                nix.settings.trusted-users = [ "@wheel" ];
                networking.hostName = config.settings.hw.hostName;
                networking.hostId = config.settings.hw.hostId;
              }
            )
          ];
        };

      # Wiring shared by mkHome and mkProfile: args, vars, overlays, identity.
      homeCommonModules = name: varsFile: [
        {
          _module.args = args // {
            inherit unstable;
            hostname = name;
          };
        }
        ./modules/vars-schema.nix
        (
          { config, ... }:
          {
            settings = import varsFile;
            nixpkgs.overlays = [ (import ./overlays) ];
            programs.home-manager.enable = true;
            home = {
              username = config.settings.usr.name;
              homeDirectory = "/home/${config.settings.usr.name}";
              stateVersion = "26.05";
            };
          }
        )
      ];
      mkHome =
        hostname:
        inputs.home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = homeCommonModules hostname ./hosts/${hostname}/vars.nix ++ [
            ./hosts/${hostname}/home.nix
            ./hm/base.nix
            ./hm/${hostRole hostname}.nix
          ];
        };
      # A profile is a Home Manager config without a NixOS host (non-NixOS
      # machine), so it composes the headless and devops layers explicitly.
      mkProfile =
        name:
        inputs.home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = homeCommonModules name ./profiles/${name}/vars.nix ++ [
            ./profiles/${name}/home.nix
            ./hm/base.nix
            ./hm/headless.nix
            ./hm/devops.nix
            { targets.genericLinux.enable = true; }
          ];
        };
      mkBaseEnv =
        pkgs:
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
          pathsToLink = [
            "/bin"
            "/etc"
            "/share"
          ];
        };
    in
    flake-utils.lib.eachSystemPassThrough [ system ] (_: {
      homeConfigurations = lib.genAttrs (hostsWith "home.nix") mkHome // {
        devops = mkProfile "devops";
      };
      nixosConfigurations = lib.genAttrs (hostsWith "configuration.nix") mkHost;
      templates = {
        rust = {
          path = ./templates/rust;
          description = "Rust template, using buildRustPackage";
        };
      };
      defaultTemplate = self.templates.rust;
    })
    // flake-utils.lib.eachSystem [ system ] (_: {
      packages.radicle-node = pkgs.dockerTools.buildLayeredImage {
        name = "simisimis/radicle-node";
        tag = "latest";
        contents = [
          pkgs.radicle-node
          (mkBaseEnv pkgs)
        ];

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
