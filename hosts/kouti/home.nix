# backute specific home manager configuration
{ config, pkgs, unstable, lib, ... }:
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
    signing.key = "C455F25E7EB90CA0";
    settings = {
      user.email = config.settings.usr.email;
      user.name = config.settings.usr.fullName;
      github.user = config.settings.usr.username;
    };
  };

  home.username = config.settings.usr.name;
  home.homeDirectory = "/home/${config.settings.usr.name}";

}
