# siMONSTER host specific configuration
{ config, lib, ... }: {
  imports = [
    ./hardware-configuration.nix
    ../../nixos/initrd-unlock.nix
  ];

  # Narrower than the "@wheel" default set by mkHost; mkForce keeps it exact.
  nix.settings.trusted-users = lib.mkForce [ "root" config.settings.usr.name ];
  nix.settings.allowed-users = [ "root" config.settings.usr.name ];

  boot.initrd.kernelModules = [ "r8169" ];

  networking.interfaces.enp5s0.useDHCP = true;
  networking.interfaces.enp5s1.useDHCP = false;
  networking.firewall = {
    enable = true;
    allowedUDPPorts = [ config.services.tailscale.port ];
  };

  security.pam.services.swaylock = { };

  services.udev.extraRules = ''
    # saleae logic analyser
    SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="21a9", ATTR{idProduct}=="1001", MODE="0666"
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="10:98:19:57:bc:9d", NAME="enp5s1"
  '';
}
