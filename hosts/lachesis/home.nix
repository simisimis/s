# lachesis specific home manager configuration
{ config, pkgs, unstable, lib, ... }: {
  imports = [ ../../hm/modules/helix ];
  programs.helix.enable = true;

  programs.git = {
    signing.key = "B66B876341173164";
    settings = {
      user.email = config.settings.usr.email;
      user.name = config.settings.usr.fullName;
      github.user = config.settings.usr.username;
    };
  };
}
