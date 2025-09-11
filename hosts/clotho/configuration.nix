# The Moirai (Fates)
#    Clotho (spins the thread of life)
#    Lachesis (measures it)
#    Atropos (cuts it)
{ config, lib, pkgs, ... }: {
  settings = import ./vars.nix;

  imports = [
    ../../nixos/base.nix
    ../../modules/settings.nix
    ../../modules/k3s
    ./hardware-configuration.nix
    ./disko-config.nix
  ];

  nix.settings.trusted-users = [ "@wheel" ];
  nixpkgs.overlays = [ (import ../../overlays) ];

  boot.kernel.sysctl = {
    "net.core.wmem_max" = 7500000;
    "net.core.rmem_max" = 7500000;
  };
  boot.initrd = {
    kernelModules = [ "igc" ];
    secrets = { "/etc/secrets/initrd/initrd-openssh-key" = null; };
    network = {
      enable = true;
      ssh = {
        enable = true;
        port = 2222;
        hostKeys = [ /etc/secrets/initrd/initrd-openssh-key ];
        authorizedKeys = [
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDS2T9+Qp59L9WbAI4/tT4YgP3V4N8rLVPkLxlYDvrZ+Wz0CHzzCSWP6DsD//UIKsVkf+gG4w320mx/kj8rL+qaj6xnMheL/Pt8S4i7gt3fAknoyj9PvSY00cis8g9bWYq1kESls33zase6eaR0NAAwg+6ujc6sAGN9/ipp5ivzExo74slp0EgQpS6VAWyhxa1XOSm5iOT1poA+SSVSdWvIYcL0IiCdTMlU06MP15tHzyA8IeFLvD7WwNQjAcQmoxrxYE9+QnkOJkAkY0TyPDV47ub4VqOM3nCNWsL9MSFh9GGFNr6c6w4Xr67vm2cZFwQ2Qq4//jpXvH8hHfTbNdrN"
        ];
      };
      postCommands = ''
        echo "zfs load-key -a; killall zfs" >> /root/.profile
      '';
    };
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    hostId = config.settings.hw.hostId;
    hostName = config.settings.hw.hostName;
    interfaces.enp3s0.useDHCP = true;
    interfaces.wlp1s0.useDHCP = true;

    wireless = {
      enable = true; # Enables wireless support via wpa_supplicant.
      interfaces = [ "wlp1s0" ];
      networks = (lib.mapAttrs (name: value: { pskRaw = "${value}"; })
        config.settings.hw.wifi); # //
      #{ "ssid" = {
      # psk = "password";
      #  extraConfig = ''
      #    key_mgmt=NONE
      #    '';
      #  };
      #};

      extraConfig = ''
        ctrl_interface=/run/wpa_supplicant
        ctrl_interface_group=wheel
      '';
    };

    firewall = {
      enable = false;

      trustedInterfaces = [ "tailscale0" ];
      allowedUDPPorts = [ config.services.tailscale.port 8472 ];
      allowedTCPPorts = [ 1400 6443 2379 2380 ];
      checkReversePath = "loose";
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
    cloudflared
    pinentry-curses
    home-manager
    tailscale
    pv
    pciutils
  ];

  services.tailscale.enable = true;

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJr0kbjhI/GRS7eAy9CaJJzxELhGgOzZTWOOzKUpgCAO"
  ];
  users.users."${config.settings.usr.name}".openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJr0kbjhI/GRS7eAy9CaJJzxELhGgOzZTWOOzKUpgCAO"
  ];
  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;
  services.syncthing = { enable = false; };

  # Virtualization
  virtualisation.docker.enable = false;
}
