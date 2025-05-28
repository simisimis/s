# siMONSTER host specific configuration
{ config, pkgs, ... }:
{
  settings = import ./vars.nix;

  imports = [
    ../../nixos/base.nix
    ../../nixos/workstation.nix
    ../../modules/settings.nix
    ./hardware-configuration.nix
  ];

  nixpkgs.overlays = [ (import ../../overlays) ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostId = config.settings.hw.hostId;
  networking.hostName = config.settings.hw.hostName;
  networking.interfaces.enp5s0.useDHCP = true;
  networking.interfaces.enp5s1.useDHCP = true;


  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  security.pam.services.swaylock = { };
  #virtualisation.virtualbox.host.enableExtensionPack = true;
  services.openssh.enable = true;

  services.udev.extraRules = ''
    # saleae logic analyser
    SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="21a9", ATTR{idProduct}=="1001", MODE="0666"
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="10:98:19:57:bc:9d", NAME="enp5s1"
  '';

  services.syncthing = {
    enable = true;
    user = config.settings.usr.name;
    configDir = "/home/${config.settings.usr.name}/${config.settings.services.syncthing.configDir}";
    settings = {
      folders = {
        "papyrus" = {
          path = "/home/${config.settings.usr.name}/${config.settings.services.syncthing.dataDir}";
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
