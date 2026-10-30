# kouti host specific configuration
{
  config,
  lib,
  pkgs,
  ...
}:
let
  keys = import ../../modules/keys.nix;
in
{
  imports = [
    ./hardware-configuration.nix
  ];

  boot.initrd.kernelModules = [ "igc" ];
  users.users."${config.settings.usr.name}".openssh.authorizedKeys.keys = [ keys.icarus ];

  networking = {
    interfaces.enp3s0.useDHCP = true;
    interfaces.wlp1s0.useDHCP = true;

    wireless = {
      enable = true; # Enables wireless support via wpa_supplicant.
      interfaces = [ "wlp1s0" ];
      networks = (lib.mapAttrs (name: value: { pskRaw = "${value}"; }) config.settings.hw.wifi);
    };

    firewall = {
      enable = true;
      allowedTCPPorts = [ 1400 ];
    };

  };

  services.k3s.enable = true;

  # List services that you want to enable:
  services.resolved.enable = true;
  services.tailscale = {
    openFirewall = true;
    # Keep tailscaled from managing iptables. Its netfilter mode also sets
    # net.ipv4.conf.all.src_valid_mark=1, which makes the kernel drop
    # Cilium Envoy -> same-node pod replies (Gateway API 503s).
    extraSetFlags = [ "--netfilter-mode=off" ];
  };

  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    settings = {
      folders = {
        "papyrus" = {
          path = config.services.syncthing.dataDir + "/papyrus";
        };
      };
    };
  };

  # Virtualization
  virtualisation.docker.enable = true;
}
