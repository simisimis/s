# lavirinthos host specific configuration
{ config, lib, nixpkgs-unstable, ... }:
let
  pkgs = import nixpkgs-unstable {
    system = "x86_64-linux";
    config = { allowUnfree = true; };
  };
in
{
  settings = import ./vars.nix;

  imports = [
    ../../nixos/base.nix
    ../../nixos/workstation.nix
    ../../modules/settings.nix
    ./hardware-configuration.nix
  ];
  nixpkgs.overlays = [
    (import ../../overlays)
  ];
  networking.hosts = {};

  hardware.firmware = with pkgs; [
    ipu6ep-camera-bin
    linux-firmware
    sof-firmware
  ];
  hardware.ipu6 = {
    enable = true;
    platform = "ipu6ep";
  };
  systemd.services.v4l2-relayd = {
    enable = true;
    wantedBy = [ "multi-user.target" ];
  };
  hardware.enableAllFirmware = true;
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
    ];
  };
  boot.kernelPackages = pkgs.zfs.latestCompatibleLinuxPackages;
  boot.extraModulePackages = with config.boot.kernelPackages; [
    ipu6-drivers
    v4l2loopback
  ];
  services = {
    zfs = {
      trim.enable = true;
      autoScrub.enable = true;
    };
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.efi.canTouchEfiVariables = true;
  networking.hostId = config.settings.hw.hostId;
  networking.hostName = config.settings.hw.hostName;

  #virtualisation.virtualbox.host.enableExtensionPack = true;

  networking.interfaces.wlp0s20f3.useDHCP = true;
  # networking.interfaces.eth0.useDHCP = true;

  networking.wireless = {
    enable = true;  # Enables wireless support via wpa_supplicant.
    interfaces = ["wlp0s20f3"];
    networks = lib.mapAttrs
      ( name: value: {
        pskRaw = "${value}";
      }) config.settings.hw.wifi;
    extraConfig = ''
      ctrl_interface=/run/wpa_supplicant
      ctrl_interface_group=wheel
    '';
  };
  environment.systemPackages = with pkgs; [
    tailscale
    dmidecode
    libva-utils
    gnome.cheese
    home-manager
    docker-compose
    chrysalis
  ];

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  #hardware.video.hidpi.enable = true;

  # Virtualization
  virtualisation.docker = {
    enable = true;
    storageDriver = "zfs";
  };

  # List services that you want to enable:
  services.logind.extraConfig = "HandlePowerKey=suspend";
 
  services.zfs.autoSnapshot = {
    enable = true;
    hourly = 0;
    daily = 7;
    weekly = 1;
    monthly = 1;
    frequent = 0;
  };
  services.udev.packages = [pkgs.chrysalis];
  services.udev.extraRules = ''
  SUBSYSTEM=="intel-ipu6-psys", MODE="0660", GROUP="video"
  ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="intel_backlight", GROUP="wheel", MODE="0664"
  # saleae logic analyser
  SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="21a9", ATTR{idProduct}=="1001", MODE="0666"
  '';
  networking.firewall = {
    # enable the firewall
    enable = true;

    # always allow traffic from your Tailscale network
    trustedInterfaces = [ "tailscale0" ];

    # allow the Tailscale UDP port through the firewall
    allowedUDPPorts = [ config.services.tailscale.port ];

    # allow you to SSH in over the public internet
    allowedTCPPorts = [ ];
    checkReversePath = "loose";
  };

  services.tailscale.enable = true;
  services.openssh.enable = false;
  services.openssh.openFirewall = false;
  # Open ports in the firewall.
  #networking.firewall.allowedTCPPorts = [ 8033 ];
  services.fwupd.enable = true;

  environment.etc = {
    "wireplumber/bluetooth.lua.d/51-bluez-config.lua".text = ''
      bluez_monitor.properties = {
        ["bluez5.enable-sbc-xq"] = true,
        ["bluez5.enable-msbc"] = true,
        ["bluez5.enable-hw-volume"] = true,
        ["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]"
      }
    '';
  };
  services.pipewire  = {
    wireplumber.enable = true;
  };

  services.syncthing = {
    enable = true;
    # Folder for Syncthing's settings and keys
    configDir = "/home/${config.settings.usr.name}/${config.settings.services.syncthing.configDir}";
    folders = {
      "papyrus" = {
        path = "/home/${config.settings.usr.name}/${config.settings.services.syncthing.dataDir}";
      };
    };
  };

  security.pam.services.swaylock = {};
  security.sudo.enable = true;
  security.sudo.extraRules = [{
    groups = [ "wheel" ];
    commands = [{
      command = "/run/current-system/sw/bin/openconnect";
      options = [ "NOPASSWD" ];
    }];
  }];
}

