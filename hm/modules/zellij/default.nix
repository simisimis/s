{ lib, pkgs, nixpkgs-unstable, config, ... }:
let
  unstable = import nixpkgs-unstable {
    system = "x86_64-linux";
    config = {
      allowUnfree = true;
    };
  };
in
{
  config = lib.mkIf config.programs.zellij.enable {
    programs.zellij = {
      package = unstable.zellij;
      settings = {
        keybinds = {
          unbind = "Ctrl b";
          shared_except = {
            _args = [ "locked" ];
            bind = {
              _args = [ "Ctrl q" ];
              "" = "Detach";
            };
          };
        };
        scrollback_editor = lib.getExe pkgs.helix;
        pane_frames = false;
        default_layout = "layout";
        theme = "gruvbox-dark";
        themes = {
          gruvbox-dark = {
            fg = "#D5C4A1";
            bg = "#737994";
            black = "#3C3836";
            red = "#CC241D";
            green = "#98971A";
            yellow = "#D79921";
            blue = "#3C8588";
            magenta = "#B16286";
            cyan = "#689D6A";
            white = "#FBF1C7";
            orange = "#D65D0E";
          };
        };
      };
    };

    xdg.configFile."zellij/layouts/layout.kdl".source = ./layout.kdl;

    programs.zsh.initExtraBeforeCompInit = ''
      if [[ $TERM != "screen-256color" && $TERM != "linux" && -z "$ZELLIJ" ]] ; then
        if [[ $(zellij ls 2>/dev/null |grep ^work$) = "work" ]]; then
          zellij attach 'work'
        else
          zellij attach -c 'work'
        fi
      fi
    '';
  };
}
