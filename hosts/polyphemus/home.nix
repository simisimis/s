# polyphemus specific home manager configuration
{ config, pkgs, nixpkgs-unstable, lib, ... }:
let
  unstable = import nixpkgs-unstable {
    system = "x86_64-linux";
    config = { allowUnfree = true; };
  };
in
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
