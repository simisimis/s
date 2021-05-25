# siMONSTER host specific configuration
{ config, ... }:
{
  settings = import ./vars.nix;

  imports = [
    ../../nixos/base.nix
    ../../modules/settings.nix
    ./hardware-configuration.nix
  ];

  home-manager.users."${config.settings.usr.name}" = import ./home.nix { inherit config; };

  networking.hostId = config.settings.hw.hostId;
  networking.hostName = config.settings.hw.hostName;
  networking.interfaces.enp5s0.useDHCP = true;

  virtualisation.virtualbox.host.enableExtensionPack = true;
}
