# siMONSTER host specific configuration
{ config, ... }:
{
  settings = import ./vars.nix;

  imports = [
    ../../nixos/base.nix
    ../../modules/settings.nix
    ./hardware-configuration.nix
  ];

  home-manager.users."${config.settings.usr.name}".imports = [
    ./home.nix
    ../../hm/base.nix
    ../../hm/workstation.nix
  ];
  networking.hostId = config.settings.hw.hostId;
  networking.hostName = config.settings.hw.hostName;
  networking.interfaces.enp5s0.useDHCP = true;

  hardware.video.hidpi.enable = true;
  security.pam.services.swaylock = {};
  #virtualisation.virtualbox.host.enableExtensionPack = true;
  services.openssh.enable = true;
}
