# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, nixpkgs-unstable, ... }:
let
  unstable = import nixpkgs-unstable {
    system = "x86_64-linux";
    config = { allowUnfree = true; };
  };
in
{
  settings = import ./vars.nix;

  imports = [
    ../../nixos/base.nix
    ../../modules/settings.nix
    ./hardware-configuration.nix
    ./proxy.nix
  ];

  # import overlays
  nixpkgs.overlays = [ (import ../../overlays) ];

  boot.initrd = {
    kernelModules = [ "igc" ];
    network = {
      enable = true;
      ssh = {
        enable = true;
        port = 2222;
        hostKeys = [ "/etc/secrets/initrd/initrd-openssh-key" ];
        authorizedKeys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDS2T9+Qp59L9WbAI4/tT4YgP3V4N8rLVPkLxlYDvrZ+Wz0CHzzCSWP6DsD//UIKsVkf+gG4w320mx/kj8rL+qaj6xnMheL/Pt8S4i7gt3fAknoyj9PvSY00cis8g9bWYq1kESls33zase6eaR0NAAwg+6ujc6sAGN9/ipp5ivzExo74slp0EgQpS6VAWyhxa1XOSm5iOT1poA+SSVSdWvIYcL0IiCdTMlU06MP15tHzyA8IeFLvD7WwNQjAcQmoxrxYE9+QnkOJkAkY0TyPDV47ub4VqOM3nCNWsL9MSFh9GGFNr6c6w4Xr67vm2cZFwQ2Qq4//jpXvH8hHfTbNdrN" ];
      };
      postCommands = ''
        echo "zfs load-key -a; killall zfs" >> /root/.profile
      '';
    };
  };

  boot.kernelPackages = pkgs.zfs.latestCompatibleLinuxPackages;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.efi.canTouchEfiVariables = true;
  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.hostId = config.settings.hw.hostId;
  networking.hostName = config.settings.hw.hostName;
  networking.interfaces.enp3s0.useDHCP = true;
  networking.interfaces.wlp1s0.useDHCP = true;

  networking.wireless = {
    enable = true; # Enables wireless support via wpa_supplicant.
    interfaces = [ "wlp1s0" ];
    networks = (lib.mapAttrs
      (name: value: {
        pskRaw = "${value}";
      })
      config.settings.hw.wifi); #//
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

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  # environment.systemPackages = with pkgs; [
  #   wget vim
  # ];
  environment.systemPackages = with pkgs; [
    cloudflared
    home-manager
    tailscale
    pv
    pciutils
  ];
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  #   pinentryFlavor = "gnome3";
  # };

  # Enable the OpenSSH daemon.
  networking.firewall = {
    # enable the firewall
    enable = true;

    # always allow traffic from your Tailscale network
    trustedInterfaces = [ "tailscale0" ];

    allowedUDPPorts = [ config.services.tailscale.port ];

    allowedTCPPorts = [ ];

    checkReversePath = "loose";
  };

  # List services that you want to enable:
  # Tailscale
  services.tailscale.enable = true;
  #services.tailscale.permitCertUid = "traefik";

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;
  services.syncthing.enable = false;
  # networking.firewall.enable = false;

  # Enable sound.
  sound.enable = false;
  # hardware.pulseaudio.enable = true;

  # Virtualization
  virtualisation.docker.enable = true;
  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      gitwitt = {
        image = "simisimis/gitwitt:0.1.0";
        extraOptions = [
          "--security-opt=no-new-privileges"
        ];
        environment = { };
        volumes = [ ];
        labels = {
          "traefik.enable" = "true";
          "traefik.http.routers.gitwitt.rule" = "Host(`gitwitt.narbuto.lt`)";
          "traefik.http.routers.gitwitt.entryPoints" = "https";
          "traefik.http.routers.gitwitt.tls.certresolver" = "letsEncrypt";
          "traefik.http.routers.gitwitt.service" = "gitwitt";
          "traefik.http.services.gitwitt.loadbalancer.server.port" = "8080";
        };
      };
    };
  };

}

