# The Moirai (Fates)
#    Clotho (spins the thread of life)
#    Lachesis (measures it)
#    Atropos (cuts it)
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
    ./disko-config.nix
  ];

  boot.kernel.sysctl = {
    "net.core.wmem_max" = 7500000;
    "net.core.rmem_max" = 7500000;
  };
  boot.initrd.kernelModules = [ "igc" ];

  networking = {
    interfaces.enp3s0.useDHCP = true;
    interfaces.wlp1s0.useDHCP = true;

    wireless = {
      enable = false;
      interfaces = [ "wlp1s0" ];
      networks = (lib.mapAttrs (name: value: { pskRaw = "${value}"; }) config.settings.hw.wifi);
      extraConfig = ''
        ctrl_interface=/run/wpa_supplicant
        ctrl_interface_group=wheel
      '';
    };

    firewall = {
      enable = true;
      allowedTCPPorts = [ 1400 ];
    };

  };
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    etcd
    helmfile
  ];

  services.k3s.enable = true;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;

    #settings = { General = { Experimental = true; }; };
  };

  services.tailscale = {
    openFirewall = true;
    # Keep tailscaled from managing iptables. Its netfilter mode also sets
    # net.ipv4.conf.all.src_valid_mark=1, which makes the kernel drop
    # Cilium Envoy -> same-node pod replies (Gateway API 503s).
    extraSetFlags = [ "--netfilter-mode=off" ];
  };

  users.users."${config.settings.usr.name}".openssh.authorizedKeys.keys = [
    keys.icarus
  ];
  services.syncthing = {
    enable = false;
  };

  # Virtualization
  virtualisation.docker.enable = false;
}
