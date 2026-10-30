# kouti host specific configuration
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
    ./hardware-configuration.nix
    ../../modules/k3s
  ];

  boot.initrd = {
    kernelModules = [ "igc" ];
    systemd = {
      extraBin.initrd-unlock = "${initrdUnlockShell}";
      users.root.shell = initrdUnlockShell;
    };
    network = {
      enable = true;
      ssh = {
        enable = true;
        port = 2222;
        hostKeys = [ "/etc/secrets/initrd/initrd-openssh-key" ];
        authorizedKeys = [ keys.initrd ];
      };
    };
  };
  users.users."${config.settings.usr.name}".openssh.authorizedKeys.keys = [ keys.icarus ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.zfs.forceImportRoot = false;

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
      trustedInterfaces = [ "tailscale0" ];
      allowedTCPPorts = [ 1400 ];
    };

  };
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    cilium-cli
    kubectl
    kubernetes-helm
    home-manager
    tailscale
    pv
    pciutils
    esphome
    immich-cli
  ];

  # List services that you want to enable:
  services.resolved.enable = true;
  services.tailscale = {
    enable = true;
    openFirewall = true;
    # Keep tailscaled from managing iptables. Its netfilter mode also sets
    # net.ipv4.conf.all.src_valid_mark=1, which makes the kernel drop
    # Cilium Envoy -> same-node pod replies (Gateway API 503s).
    extraSetFlags = [ "--netfilter-mode=off" ];
  };

  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;
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
