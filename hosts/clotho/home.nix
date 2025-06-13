# clotho specific home manager configuration
{ config, pkgs, nixpkgs-unstable, lib, ... }:
let
  unstable = import nixpkgs-unstable {
    system = "x86_64-linux";
    config = { allowUnfree = true; };
  };
in
{
  imports = [
    ../../hm/modules/helix
  ];
  programs.helix.enable = true;

  settings = import ./vars.nix;
  # import overlays
  nixpkgs.overlays = [ (import ../../overlays) ];
  programs.home-manager.enable = true;
  programs.git = {
    userName = config.settings.usr.fullName;
    userEmail = config.settings.usr.email;
    signing.key = "2920A534209891E7";
    extraConfig = {
      github.user = config.settings.usr.username;
    };
  };

  home.username = config.settings.usr.name;
  home.homeDirectory = "/home/${config.settings.usr.name}";

}
