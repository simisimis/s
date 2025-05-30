# lavirinthos host specific configuration
{ config, lib, pkgs, ... }:
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
  networking.hosts = { };

  hardware.firmware = with pkgs; [
    linux-firmware
    sof-firmware
  ];
  systemd.services.v4l2-relayd = {
    enable = true;
    wantedBy = [ "multi-user.target" ];
  };
  hardware.enableAllFirmware = true;
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      vpl-gpu-rt
    ];
  };
  #boot.kernelPackages = pkgs.zfs.latestCompatibleLinuxPackages;
  boot.extraModulePackages = with config.boot.kernelPackages; [
    # ipu6-drivers
    # ivsc-driver
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
  networking.interfaces.eth0.useDHCP = true;

  networking.wireless = {
    enable = true; # Enables wireless support via wpa_supplicant.
    interfaces = [ "wlp0s20f3" ];
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
  networking.wg-quick.interfaces.wg0 = {
    address = config.settings.hw.wg.addresses;
    dns = config.settings.hw.wg.dns;
    privateKey = config.settings.hw.wg.privateKey;

    peers = lib.mapAttrsToList
      (client: clientAttrs: {
        publicKey = clientAttrs.publicKey;
        allowedIPs = clientAttrs.allowedIPs;
        endpoint = clientAttrs.endpoint;
        persistentKeepalive = 25;
      })
      config.settings.hw.wg.peers;
  };
  environment.systemPackages = with pkgs; [
    zoom-us
    tailscale
    dmidecode
    libva-utils
    cheese
    home-manager
    docker-compose
    chrysalis
  ];

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  #hardware.video.hidpi.enable = true;
  hardware.ledger.enable = true;

  # Virtualization
  virtualisation.docker = {
    enable = true;
    storageDriver = "zfs";
  };
  users.users."${config.settings.usr.name}".extraGroups = [ "trezord" ];

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
  services.udev.packages = [ pkgs.chrysalis pkgs.trezor-udev-rules pkgs.openocd ];
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
    allowedUDPPorts = [ config.services.tailscale.port 51820 ];

    # allow you to SSH in over the public internet
    allowedTCPPorts = [ ];
    checkReversePath = "loose";
  };

  services = {
    trezord.enable = true;
  };
  services.tailscale.enable = false;
  services.openssh.enable = false;
  services.openssh.openFirewall = false;
  # Open ports in the firewall.
  #networking.firewall.allowedTCPPorts = [ 8033 ];
  services.fwupd.enable = true;

  services.pipewire = {
    #package = unstable.pipewire;
    wireplumber.enable = true;
    wireplumber.extraConfig."10-bluez" = {
      "monitor.bluez.properties" = {
        "bluez5.enable-sbc-xq" = true;
        "bluez5.enable-msbc" = true;
        "bluez5.enable-hw-volume" = true;
        "bluez5.roles" = [
          "hsp_hs"
          "hsp_ag"
          "hfp_hf"
          "hfp_ag"
        ];
      };
    };
  };

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

  security.pam.services.swaylock = { };
  security.sudo.enable = true;
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
