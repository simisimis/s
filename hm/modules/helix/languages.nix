{ config, pkgs, lib, ... }:
with pkgs; {
  home.packages = [
    shellcheck
    nodePackages.bash-language-server
    dockerfile-language-server
    nodePackages.yaml-language-server
    nodePackages.vscode-json-languageserver
    nodePackages.prettier
    nixfmt-classic
    nil
    clang-tools
    terraform-ls
    gopls
    rustfmt
    helix-gpt
    shfmt
    typescript-language-server
  ];
  programs.helix.languages = {
    language = [
      {
        name = "bash";
        language-servers = [ "bash-language-server" "buffer-language-server" ];
        file-types = [ "sh" "bash" "zsh" ];
        formatter = {
          command = lib.getExe shfmt;
          args = [ "-i" "2" "-" ];
        };
        auto-format = true;
      }
      {
        name = "nix";
        auto-format = true;
        formatter = { command = lib.getExe nixfmt-classic; };
        language-servers = [ "nil" "buffer-language-server" ];
      }
      {
        name = "hcl";
        auto-format = true;
        language-id = "terraform";
        language-servers = [ "terraform" "buffer-language-server" ];
      }
      {
        name = "tfvars";
        auto-format = true;
        language-id = "terraform-vars";
        language-servers = [ "terraform" "buffer-language-server" ];
      }
      {
        name = "rust";
        auto-format = true;
        language-servers = [ "rust-analyzer" "buffer-language-server" ];
        formatter = {
          command = lib.getExe rustfmt;
          args = [ "--edition" "2024" ];
        };
      }
      {
        name = "go";
        auto-format = true;
        language-servers = [ "gopls" "buffer-language-server" ];
      }
      {
        name = "gotmpl";
        auto-format = true;
        language-servers = [ "gopls" "buffer-language-server" ];
        file-types = [ "yaml" "tpl" ];
      }
      {
        name = "toml";
        file-types = [ ".editorconfig" "toml" ];
      }
      {
        name = "yaml";
        language-servers = [ "yaml-language-server" "buffer-language-server" ];
        file-types = [ ];
      }
      {
        name = "json";
        auto-format = true;
        language-servers =
          [ "vscode-json-language-server" "buffer-language-server" ];
        formatter = {
          args = [ "--parser" "json" ];
          command = "prettier";
        };
      }
      {
        name = "markdown";
        language-servers = [ "buffer-language-server" ];
      }
      {
        name = "typescript";
        language-servers =
          [ "typescript-language-server" "buffer-language-server" ];
        auto-format = true;
      }
    ];
    language-server = {
      gpt = {
        command = lib.getExe helix-gpt;
        args = [
          "--handler"
          "copilot"
          "--copilotApiKey"
          "${config.settings.programs.helix.copilotApiKey}"
        ];
      };
      buffer-language-server = { command = "buffer-language-server"; };
      bash-language-server = {
        command = lib.getExe nodePackages.bash-language-server;
        args = [ "start" ];
      };
      gopls = { command = lib.getExe gopls; };
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
        config = { yaml.keyOrdering = false; };
      };
      terraform = {
        command = lib.getExe terraform-ls;
        args = [ "serve" ];
        filetypes = [ "terraform" "hcl" ];
      };

      docker-langserver = {
        command = lib.getExe dockerfile-language-server;
        args = [ "--stdio" ];
      };
      vscode-json-language-server = {
        command = lib.getExe nodePackages.vscode-json-languageserver;
        args = [ "--stdio" ];
        config = { provideFormatter = true; };
      };
      nil = {
        command = lib.getExe nil;
        config = {
          formatting.command = [ (lib.getExe nixfmt-classic) ];
          nix.flake.autoEvalInputs = true;
        };
      };
      clangd = { command = "${pkgs.clang-tools}/bin/clangd"; };
    };
  };
}
