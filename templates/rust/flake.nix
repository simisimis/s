{
  description = "CHANGEME";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, fenix }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ fenix.overlays.default ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };

      in
      with pkgs;
      {
        devShells.default = mkShell {
          buildInputs = [
            just
            bacon
            (fenix.packages.${system}.stable.withComponents [
              "cargo"
              "clippy"
              "rust-src"
              "rustc"
              "rustfmt"
              "rust-analyzer"
              "llvm-tools-preview"
            ])
            rust-analyzer
          ];
          shellHook = ''
            cat <<EOF
            Welcome to the 'CHANGEME' development shell.

            $(just -l |sed 's/^Available recipes:/The following `just` recipes are available:/')
            EOF
            user_shell=$(getent passwd "$(whoami)" |cut -d: -f 7)
            exec "$user_shell"
          '';
        };
      }
    );
}
