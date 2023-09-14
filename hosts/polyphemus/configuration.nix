# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, nixpkgs-unstable, ... }:
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
    ];

  # import overlays
  nixpkgs.overlays = [ (import ../../overlays) ];

  boot = {
  # Use the systemd-boot EFI boot loader.
    initrd.kernelModules = [ "virtio_pci" ]; 
    initrd.network = {
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

  # Use grup mbr boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.configurationLimit = 1;

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.hostId = config.settings.hw.hostId;
  networking.hostName = config.settings.hw.hostName;
  networking.interfaces.ens3.useDHCP = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  # environment.systemPackages = with pkgs; [
  #   wget vim
  # ];
  environment.systemPackages = with pkgs; [
    tailscale
    pv
    docker-compose
    rclone
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

  # List services that you want to enable:
  # Enable the OpenSSH daemon.
    networking.firewall = {
    # enable the firewall
    enable = true;
    allowedTCPPorts = [ 22 443 80 8080 ];

    # always allow traffic from your Tailscale network
    trustedInterfaces = [ "tailscale0" ];

    # allow the Tailscale UDP port through the firewall
    allowedUDPPorts = [ config.services.tailscale.port ];

    # allow you to SSH in over the public internet
    checkReversePath = "loose";
  };

  services.syncthing.enable = false;

  services.tailscale.enable = true;

  services.openssh.enable = true;
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable sound.
  sound.enable = false;
  # hardware.pulseaudio.enable = true;

  # Virtualization
  virtualisation.docker.enable = true;

}
