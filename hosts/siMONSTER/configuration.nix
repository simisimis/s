# siMONSTER host specific configuration
{ config, lib, pkgs, ... }:
let
  keys = import ../../modules/keys.nix;
  zfsCompatibleKernelPackages = lib.filterAttrs (name: kernelPackages:
    (builtins.match "linux_[0-9]+_[0-9]+" name) != null
    && (builtins.tryEval kernelPackages).success
    && (!kernelPackages.${config.boot.zfs.package.kernelModuleAttribute}.meta.broken))
    pkgs.linuxKernel.packages;
  latestKernelPackage = lib.last
    (lib.sort (a: b: (lib.versionOlder a.kernel.version b.kernel.version))
      (builtins.attrValues zfsCompatibleKernelPackages));
  initrdUnlockShell = pkgs.writeShellScript "initrd-zfs-unlock-shell" ''
    echo "Waiting for initrd password prompts"
    exec ${config.boot.initrd.systemd.package}/bin/systemd-tty-ask-password-agent
  '';
in {
  imports = [
    ./hardware-configuration.nix
  ];

  # Narrower than the "@wheel" default set by mkHost; mkForce keeps it exact.
  nix.settings.trusted-users = lib.mkForce [ "root" config.settings.usr.name ];
  nix.settings.allowed-users = [ "root" config.settings.usr.name ];

  # Use the systemd-boot EFI boot loader.
  boot.kernelPackages = latestKernelPackage;
  boot.zfs.package = pkgs.zfs_unstable;
  boot.zfs.forceImportRoot = false;

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd = {
    kernelModules = [ "r8169" ];
    secrets = { "/etc/secrets/initrd/initrd-openssh-key" = null; };
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

  networking.interfaces.enp5s0.useDHCP = true;
  networking.interfaces.enp5s1.useDHCP = false;
  networking.firewall = {
    enable = true;
    trustedInterfaces = [ "tailscale0" ];
    allowedUDPPorts = [ config.services.tailscale.port ];
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  programs.dconf.enable = true;
  services.seatd.enable = true;
  services.zfs = {
    trim.enable = true;
    autoScrub.enable = true;
    autoSnapshot = {
      enable = true;
      hourly = 0;
      daily = 2;
      weekly = 1;
      monthly = 0;
      frequent = 0;
    };
  };
  security.pam.services.swaylock = { };
  #virtualisation.virtualbox.host.enableExtensionPack = true;
  services.tailscale.enable = true;
  services.openssh.enable = true;

  services.udev.extraRules = ''
    # saleae logic analyser
    SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="21a9", ATTR{idProduct}=="1001", MODE="0666"
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="10:98:19:57:bc:9d", NAME="enp5s1"
  '';

  services.syncthing = {
    enable = true;
    user = config.settings.usr.name;
    configDir =
      "/home/${config.settings.usr.name}/${config.settings.services.syncthing.configDir}";
    settings = {
      folders = {
        "papyrus" = {
          path =
            "/home/${config.settings.usr.name}/${config.settings.services.syncthing.dataDir}";
        };
      };
    };
  };
  security.sudo.extraRules = [{
    groups = [ "wheel" ];
    commands = [
      {
        command = "${pkgs.systemd}/bin/systemctl restart *";
        options = [ "NOPASSWD" ];
      }
      {
        command = "${pkgs.systemd}/bin/journalctl *";
        options = [ "NOPASSWD" ];
      }
    ];
  }];
}
