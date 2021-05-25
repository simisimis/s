# siMONSTER specific home manager configuration
{ config, ... }:
{
  imports = [
    ../../hm/base.nix
  ];
  programs.git = {
    userName = config.settings.usr.name;
    userEmail = config.settings.usr.email;
    extraConfig = {
      github.user = config.settings.usr.username;
    };
  };
  home.username = config.settings.usr.name;
  home.homeDirectory = "/home/${config.settings.usr.name}";
}
