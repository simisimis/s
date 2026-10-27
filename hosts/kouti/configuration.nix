# kouti host specific configuration
{
  config,
  lib,
  pkgs,
  ...
}:
let
  initrdUnlockShell = pkgs.writeShellScript "initrd-zfs-unlock-shell" ''
    echo "Waiting for initrd password prompts"
    exec ${config.boot.initrd.systemd.package}/bin/systemd-tty-ask-password-agent
  '';
in
{
  settings = import ./vars.nix;

  imports = [
    ../../nixos/base.nix
    ../../modules/vars-schema.nix
    ./hardware-configuration.nix
    ../../modules/k3s
  ];

  nix.settings.trusted-users = [ "@wheel" ];
  nixpkgs.overlays = [ (import ../../overlays) ];

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
        authorizedKeys = [
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDS2T9+Qp59L9WbAI4/tT4YgP3V4N8rLVPkLxlYDvrZ+Wz0CHzzCSWP6DsD//UIKsVkf+gG4w320mx/kj8rL+qaj6xnMheL/Pt8S4i7gt3fAknoyj9PvSY00cis8g9bWYq1kESls33zase6eaR0NAAwg+6ujc6sAGN9/ipp5ivzExo74slp0EgQpS6VAWyhxa1XOSm5iOT1poA+SSVSdWvIYcL0IiCdTMlU06MP15tHzyA8IeFLvD7WwNQjAcQmoxrxYE9+QnkOJkAkY0TyPDV47ub4VqOM3nCNWsL9MSFh9GGFNr6c6w4Xr67vm2cZFwQ2Qq4//jpXvH8hHfTbNdrN"
        ];
      };
    };
  };
  users.users."${config.settings.usr.name}".openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIKCyMzo4Y29R3xAo4RIfGmPvNGedP9Bg5ABDtBryDKz"
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.zfs.forceImportRoot = false;

  networking = {
    hostId = config.settings.hw.hostId;
    hostName = config.settings.hw.hostName;
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
