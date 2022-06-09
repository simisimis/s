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
  nix.package = pkgs.nixFlakes;

  age.secrets.secret1.file = ./secret1.age;
  nix.extraOptions = ''
    keep-outputs = true
    keep-derivations = true
    experimental-features = nix-command flakes
  '';

  nixpkgs.overlays = [ (import ../../overlays) ];

  networking.hostId = config.settings.hw.hostId;
  networking.hostName = config.settings.hw.hostName;
  networking.interfaces.enp5s0.useDHCP = true;

  hardware.video.hidpi.enable = true;
  security.pam.services.swaylock = {};
  #virtualisation.virtualbox.host.enableExtensionPack = true;
  services.openssh.enable = true;

  services.udev.extraRules = ''
  # saleae logic analyser
  SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="21a9", ATTR{idProduct}=="1001", MODE="0666"
  '';

  services.syncthing = {
    # Folder for Syncthing's settings and keys
    configDir = "/home/${config.settings.usr.name}/${config.settings.services.syncthing.configDir}";
    folders = {
      "papyrus" = {
        path = "/home/${config.settings.usr.name}/${config.settings.services.syncthing.dataDir}";
      };
    };
  };
}
