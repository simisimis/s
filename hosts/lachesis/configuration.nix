# The Moirai (Fates)
#    Clotho (spins the thread of life)
#    Lachesis (measures it)
#    Atropos (cuts it)
{
  config,
  lib,
  pkgs,
  unstable,
  ...
}:
let
  keys = import ../../modules/keys.nix;
in
{
  imports = [
    ./hardware-configuration.nix
    ./disko-config.nix
  ];

  boot.initrd.kernelModules = [ "virtio_pci" ];

  networking = {
    interfaces.ens18.useDHCP = true;

    firewall = {
      enable = true;

      allowedUDPPorts = [
        config.services.tailscale.port
        51820
      ];
      allowedTCPPorts = [ 1400 ];
    };

  };

  users.users."${config.settings.usr.name}".openssh.authorizedKeys.keys = [ keys.icarus ];
  services.syncthing = {
    enable = false;
  };

  # Virtualization
  virtualisation.docker.enable = true;
}
