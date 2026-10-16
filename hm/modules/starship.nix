{
  lib,
  pkgs,
  config,
  jj-starship,
  ...
}:
let
  jjStarship = jj-starship.packages.${pkgs.stdenv.hostPlatform.system}.default;
  jjStarshipExe = lib.getExe jjStarship;
in
{
  config = lib.mkIf config.programs.starship.enable {
    home.packages = [ jjStarship ];

    programs.starship.settings = {
      add_newline = false;
      format = "$hostname$directory$nix_shell\${custom.jj}$fill$shlvl$kubernetes$line_break$character";

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

      git_branch.disabled = true;
      git_commit.disabled = true;
      git_status.disabled = true;
      custom.jj = {
        when = "${jjStarshipExe} detect";
        shell = [
          jjStarshipExe
          "--no-jj-id"
          "--no-git-id"
        ];
        format = "$output ";
      };
      hostname.format = "[$hostname:](bold yellow)";

      line_break.disabled = false;

    };
  };
}
