{ pkgs, lib, ... }: with pkgs; {
  home.packages = [
    shellcheck
    nodePackages.bash-language-server
    nodePackages.dockerfile-language-server-nodejs
    nodePackages.yaml-language-server
    nodePackages.vscode-json-languageserver
    nodePackages.prettier
    nixpkgs-fmt
    nil
    terraform-ls
    gopls
    rustfmt
  ];
  programs.helix.languages = {
    language = [
      {
        name = "nix";
        auto-format = true;
        formatter = {
          command = lib.getExe nixpkgs-fmt;
        };
      }
      {
        name = "hcl";
        auto-format = true;
        language-server.command = lib.getExe terraform-ls;
        language-server.args = [ "serve" ];
        language-server.language-id = "terraform";
      }
      {
        name = "tfvars";
        auto-format = true;
        language-server.command = lib.getExe terraform-ls;
        language-server.args = [ "serve" ];
        language-server.language-id = "terraform-vars";
      }
      {
        name = "rust";
        auto-format = true;
        formatter = {
          command = lib.getExe rustfmt;
          args = [ "--edition" "2021" ];
        };
      }
      {
        name = "go";
        auto-format = true;
        language-server.command = lib.getExe gopls;
      }
      {
        name = "gotmpl";
        auto-format = true;
        language-server.command = lib.getExe gopls;
        file-types = [
          "yaml"
          "tpl"
        ];
      }
      {
        name = "toml";
        file-types = [
          ".editorconfig"
          "toml"
        ];
      }
      {
        name = "yaml";
        file-types = [
          "yaml"
          "yml"
        ];
        config = {
          yaml.keyOrdering = false;
        };
      }
      {
        name = "json";
        auto-format = true;
        language-server.command = lib.getExe nodePackages.vscode-json-languageserver;
        language-server.args = [ "--stdio" ];
        formatter = {
          args = [ "--parser" "json" ];
          command = "prettier";
        };
      }
      {
        name = "markdown";
        language-server = {
          command = "buffer-language-server";
        };
      }
    ];
    language-servers = {
      buffer-language-server = {
        command = "buffer-language-server";
      };
      bash-language-server = {
        command = lib.getExe nodePackages.bash-language-server;
        args = [ "start" ];
      };
      gopls = {
        command = lib.getExe gopls;
      };
      rust-analyzer = {
        command = lib.getExe rust-analyzer;
        config.rust-analyzer = {
          cargo = {
            buildScripts.enable = true;
            features = "all";
          };
          checkOnSave.command = "clippy";
          procMacro.enable = true;
        };
      };
      yaml-language-server = {
        command = lib.getExe nodePackages.yaml-language-server;
        args = [ "--stdio" ];
      };
      terraform = {
        command = lib.getExe terraform-ls;
        args = [ "serve" ];
        filetypes = [ "terraform" "hcl" ];
      };

      docker-langserver = {
        command = lib.getExe nodePackages.dockerfile-language-server-nodejs;
        args = [ "--stdio" ];
      };
      vscode-json-language-server = {
        command = lib.getExe nodePackages.vscode-json-languageserver;
        config = { provideFormatter = true; };
      };
      nil = {
        command = lib.getExe nil;
        config.nil = {
          formatting.command = [ (lib.getExe nixpkgs-fmt) ];
          nix.flake.autoEvalInputs = true;
        };
      };
    };
  };
}
