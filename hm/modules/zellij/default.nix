{ lib, pkgs, nixpkgs-unstable, config, ... }:
with lib;
let
  unstable = import nixpkgs-unstable {
    system = "x86_64-linux";
    config = {
      allowUnfree = true;
      android_sdk.accept_license = true;
    };
  };
in
  {
    config = mkIf config.programs.zellij.enable {
      programs.zellij.package = unstable.zellij;
      home.file.".config/zellij/config.kdl".source = ./config.kdl;

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
