{ lib, pkgs, config, ... }:
{
  config.programs.starship = lib.mkIf config.programs.starship.enable {
    settings = {
      add_newline = false;
      format = "$hostname$directory$nix_shell(\\($git_branch$git_commit|$git_status\\))$fill$shlvl$kubernetes$line_break$character";

      character = {
        success_symbol = "[≫](bold green) ";
        error_symbol = "[✗](bold red) ";
      };

      fill.symbol = " ";
      shlvl.disabled = false;

      directory = {
        style = "bold blue";
        repo_root_style = "bold fg:220";
        truncate_to_repo = false;
        format = "[\\[$path[$read_only]($read_only_style)\\]]($style) ";
        repo_root_format = "[\\[$before_root_path]($style)[$repo_root]($repo_root_style)[$path[$read_only]($read_only_style)\\]]($style) ";
      };

      kubernetes = {
        disabled = false;
        format = "[$context $namespace]($style)";
      };

      nix_shell = {
        format = "[\\[$symbol\\]](bold cyan) ";
        symbol = "❄️";
      };

      git_branch.format = "[$symbol$branch](purple)";
      git_commit.format = "[$hash]($style)";
      git_status = {
        format = "([$all_status$ahead_behind]($style))";
        style = "green";
        ahead = "[↑$count](blue)";
        behind = "[↓$count](red)";
        diverged = "[↑$\\{ahead_count\\}](blue)[↓$\\{behind_count\\}](red)";
        conflicted = "✗";
        up_to_date = "✔";
        untracked = "[…](red)";
        stashed = "📦";
        modified = "[+$count](red)";
        staged = "[¤$count](green)";
        deleted = "[✗$count](red)";
      };
      hostname.format = "[$hostname:](bold yellow)";

      line_break.disabled = false;

    };
  };
}
