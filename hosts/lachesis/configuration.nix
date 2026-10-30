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

  boot.initrd = {
    kernelModules = [ "virtio_pci" ];
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

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    interfaces.ens18.useDHCP = true;

    firewall = {
      enable = true;

      allowedUDPPorts = [
        8472
        config.services.tailscale.port
        51820
      ];
      allowedTCPPorts = [
        1400
        6443
        2379
        2380
      ];
      # checkReversePath is set to false by modules/k3s
    };

  };
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    kubectl
    kubernetes-helm
    home-manager
    tailscale
    pv
    pciutils
    esphome
    immich-cli
  ];

  services.tailscale.enable = true;
  services.k3s.enable = lib.mkForce false;

  users.users."${config.settings.usr.name}".openssh.authorizedKeys.keys = [ keys.icarus ];
  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;
  services.syncthing = {
    enable = false;
  };

  # Virtualization
  virtualisation.docker.enable = true;
}
