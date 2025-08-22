{ lib, pkgs, config, ... }:
let guiTools = [ pkgs.gg-jj ];
in {

  config = lib.mkIf config.programs.jujutsu.enable {
    home.packages = [ pkgs.jj-fzf pkgs.lazyjj ] ++ guiTools;
    programs.git.ignores = [ ".jj*" ];
    programs.jujutsu = {
      settings = {
        aliases = {
          "l" = [ "log" "--no-pager" "--limit=6" ];
          "s" = [ "st" "--no-pager" ];
        };

        template-aliases = {
          "format_timestamp(timestamp)" = "timestamp.ago()";
        };

        user = {
          name = config.settings.usr.fullName;
          email = config.settings.usr.email;
        };

        ui = {
          conflict-marker-style = "git";
          diff-formatter = ":git";
          movement.edit = true;
        };
      };
    };
  };
}
