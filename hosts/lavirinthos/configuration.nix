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
  environment.etc."iproute2/rt_tables.d/wg.conf".text = "200 wg_table\n";
  networking = {
    hosts = { };
    hostId = config.settings.hw.hostId;
    hostName = config.settings.hw.hostName;

    interfaces.wlp0s20f3.useDHCP = true;
    interfaces.eth0.useDHCP = true;

    wireless = {
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
    wg-quick.interfaces.wg0 = {
      address = config.settings.hw.wg.addresses;
      privateKey = config.settings.hw.wg.privateKey;

      peers = lib.mapAttrsToList
        (client: clientAttrs: {
          publicKey = clientAttrs.publicKey;
          allowedIPs = clientAttrs.allowedIPs;
          endpoint = clientAttrs.endpoint;
          persistentKeepalive = 25;
        })
        config.settings.hw.wg.peers;
      table = "wg_table";
      postUp = ''
        ip route add ${config.settings.hw.wg.ips} dev wg0 table wg_table
        ip rule add to ${config.settings.hw.wg.ips} table wg_table priority 100
      '';
      postDown = ''
        ip route del ${config.settings.hw.wg.ips} dev wg0 table wg_table
        ip rule del to ${config.settings.hw.wg.ips} table wg_table priority 100
      '';
    };
    firewall = {
      enable = true;
      trustedInterfaces = [ "tailscale0" ];
      allowedUDPPorts = [ config.services.tailscale.port 51820 ];
      allowedTCPPorts = [ ];
      checkReversePath = "loose";
    };
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
  services.resolved.enable = true;
  services.resolved.extraConfig = ''
    [Resolve]
    DNS=${lib.concatStringsSep " " config.settings.hw.wg.dns}
    Domains=~casa
  '';

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

  services = {
    trezord.enable = true;
  };
  services.tailscale.enable = true;
  services.openssh.enable = false;
  services.openssh.openFirewall = false;
  # Open ports in the firewall.
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
