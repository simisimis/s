# epiphanis specific home manager configuration
sysConfig:
{ config, pkgs, ... }:
let
  unstable = import <nixos-unstable> { config.allowUnfree = true; };
  config.settings = sysConfig.settings;
in
{
  imports = [
    ../../hm/base.nix
    ../../hm/workstation.nix
  ];
  # import overlays
  nixpkgs.overlays = [ (import ../../overlays) ];
  programs.git = {
    userName = sysConfig.settings.usr.fullName;
    userEmail = sysConfig.settings.usr.email;
    extraConfig = {
      github.user = sysConfig.settings.usr.username;
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
  home.username = sysConfig.settings.usr.name;
  home.homeDirectory = "/home/${config.settings.usr.name}";

  home.packages = with pkgs; [
    #system
    krb5
    cifs-utils
    openconnect

    #dev
    hiera-eyaml
    ruby bundix puppetgems pdk
    google-cloud-sdk
    kubectx kubectl k9s stern
    vagrant

    #web
    teams
    zoom-us
    rambox

    unstable.robo3t
    unstable.mongodb-compass

  ];
  programs.ssh = {
    matchBlocks = {
      "gitlab.bol.io" = {
        user = "git";
        identityFile = "~/.ssh/id_rsa_bolcom_io_snarbutas";
        extraOptions = {
          AddKeysToAgent = "yes";
          PubKeyAuthentication = "yes";
        };
      };
      "adm*.bolcom.net tst*bolcom.net pro*bolcom.net acc*bolcom.net xpr*bolcom.net sbx*bolcom.net shd*bolcom.net dev*bolcom.net" = { # config.lib.hm.dag.entryBefore ["adm* tst* pro* acc* xpr* sbx* shd* dev*"]
        user = "snarbutas";
        hostname = "%h";
        extraOptions = {
          ServerAliveInterval = "120";
          SendEnv = "BOL_FANCYPROMPT";
          GSSAPIAuthentication = "yes";
          GSSAPIDelegateCredentials = "yes";
          StrictHostKeyChecking = "no";
        };
      };
      "adm* tst* pro* acc* xpr* sbx* shd* dev*" = {
        user = "snarbutas";
        hostname = "%h.bolcom.net";
        extraOptions = {
          ServerAliveInterval = "120";
          SendEnv = "BOL_FANCYPROMPT";
          GSSAPIAuthentication = "yes";
          GSSAPIDelegateCredentials = "yes";
          StrictHostKeyChecking = "no";
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
