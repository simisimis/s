# epiphanis specific home manager configuration
{ nixosConfig, config, pkgs, ... }:
let
  unstable = import <nixos-unstable> { config.allowUnfree = true; };
in
{
  # import overlays
  nixpkgs.overlays = [ (import ../../overlays) ];
  programs.git = {
    userName = nixosConfig.settings.usr.fullName;
    userEmail = nixosConfig.settings.usr.email;
    extraConfig = {
      github.user = nixosConfig.settings.usr.username;
      #github.email = "simonas@narbuto.lt";
      url = {
        "ssh://git@gitlab.tools.bol.com" = {
          insteadOf = "https://gitlab.tools.bol.com";
        };
        "ssh://git@gitlab.bol.io" = {
          insteadOf = "https://gitlab.bol.io";
        };
      };
    };
  };
  home.username = nixosConfig.settings.usr.name;
  home.homeDirectory = "/home/${nixosConfig.settings.usr.name}";

  home.packages = with pkgs; [
    #system
    krb5
    cifs-utils
    openconnect
    rclone

    #dev
    hiera-eyaml
    ruby bundix puppetgems pdk
    google-cloud-sdk
    kubectx kubectl k9s stern
    vagrant

    #web
    teams
    zoom-us
    unstable.rambox

    unstable.robo3t
    unstable.mongodb-compass
  ];
  programs.ssh = {
    extraOptionOverrides = {
      CanonicalizeHostname = "yes";
      CanonicalDomains = "bolcom.net bfc.bolcom.net";
    };

    extraConfig = ''
      UseRoaming no
      AddKeysToAgent yes
    '';
    matchBlocks = {
      "*.bol.com *.bolcom.net" = {
        user = nixosConfig.settings.usr.username;
        extraOptions = {
          ServerAliveInterval = "120";
          SendEnv = "BOL_FANCYPROMPT";
          StrictHostKeyChecking = "no";
          GSSAPIAuthentication = "yes";
          GSSAPIDelegateCredentials = "yes";
        };
      };
      "gitlab.bol.io" = {
        user = "git";
        identityFile = "~/.ssh/id_rsa_bolcom_io_snarbutas";
        extraOptions = {
          PubKeyAuthentication = "yes";
        };
      };
    };
  };
  programs.zsh = {
    cdpath = [
      "~/vagrant"
    ];
    initExtra = ''
    export BOL_FANCYPROMPT="\[\033[38;5;202m\][\[\033[38;5;4m\]\t\[\033[38;5;202m\]] \[\033[38;5;3m\]\h \[\033[38;5;6m\]\W \[\033[38;5;41m\]≫\[\033[0m\] "
    '';
  };
}
