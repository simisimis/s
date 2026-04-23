# polyphemus specific home manager configuration
{ config, pkgs, unstable, lib, ... }:
{
  settings = import ./vars.nix;
  # import overlays
  nixpkgs.overlays = [ (import ../../overlays) ];
  programs.home-manager.enable = true;
  programs.git = {
    userName = config.settings.usr.fullName;
    userEmail = config.settings.usr.email;
    extraConfig = {
      github.user = config.settings.usr.username;
    };
  };
  programs.helix.enable = lib.mkForce false;
  programs.zellij.enable = lib.mkForce false;

  home.username = config.settings.usr.name;
  home.homeDirectory = "/home/${config.settings.usr.name}";

}
