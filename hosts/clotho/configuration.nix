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
  initrdUnlockShell = pkgs.writeShellScript "initrd-zfs-unlock-shell" ''
    echo "Waiting for initrd password prompts"
    exec ${config.boot.initrd.systemd.package}/bin/systemd-tty-ask-password-agent
  '';
in
{
  imports = [
    ../../modules/k3s
    ./hardware-configuration.nix
    ./disko-config.nix
  ];

  boot.kernel.sysctl = {
    "net.core.wmem_max" = 7500000;
    "net.core.rmem_max" = 7500000;
  };
  boot.initrd = {
    kernelModules = [ "igc" ];
    #secrets = { "/etc/secrets/initrd/initrd-openssh-key" = null; };
    systemd = {
      extraBin.initrd-unlock = "${initrdUnlockShell}";
      users.root.shell = initrdUnlockShell;
    };
    network = {
      enable = true;
      ssh = {
        enable = true;
        port = 2222;
        hostKeys = [ /etc/secrets/initrd/initrd-openssh-key ];
        authorizedKeys = [ keys.initrd ];
      };
    };
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.zfs.forceImportRoot = false;

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
      trustedInterfaces = [ "tailscale0" ];
      allowedTCPPorts = [ 1400 ];
    };

  };
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    etcd
    kubectl
    kubernetes-helm
    helmfile
    cilium-cli
    pinentry-curses
    home-manager
    tailscale
    pv
    pciutils
  ];

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;

    #settings = { General = { Experimental = true; }; };
  };

  services.tailscale = {
    enable = true;
    openFirewall = true;
    # Keep tailscaled from managing iptables. Its netfilter mode also sets
    # net.ipv4.conf.all.src_valid_mark=1, which makes the kernel drop
    # Cilium Envoy -> same-node pod replies (Gateway API 503s).
    extraSetFlags = [ "--netfilter-mode=off" ];
  };

  users.users."${config.settings.usr.name}".openssh.authorizedKeys.keys = [
    keys.icarus
  ];
  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;
  services.syncthing = {
    enable = false;
  };

  # Virtualization
  virtualisation.docker.enable = false;
}
