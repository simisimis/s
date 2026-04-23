# clotho specific home manager configuration
{ config, pkgs, unstable, lib, ... }:
{
  imports = [ ../../hm/modules/helix ];
  programs.helix.enable = true;

  settings = import ./vars.nix;
  # import overlays
  nixpkgs.overlays = [ (import ../../overlays) ];
  programs.home-manager.enable = true;
  programs.git = {
    userName = config.settings.usr.fullName;
    userEmail = config.settings.usr.email;
    signing.key = "355FDA1C9F563EC7";
    extraConfig = { github.user = config.settings.usr.username; };
  };

  home.username = config.settings.usr.name;
  home.homeDirectory = "/home/${config.settings.usr.name}";

}
