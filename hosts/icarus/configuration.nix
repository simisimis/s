{ config, lib, pkgs, ... }: {
  settings = import ./vars.nix;

  imports = [
    ../../nixos/base.nix
    ../../nixos/workstation.nix
    ../../modules/settings.nix
    ./hardware-configuration.nix
    ./disko-config.nix
  ];
  nixpkgs.overlays = [ (import ../../overlays) ];
  nix.settings.trusted-users = [ "@wheel" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
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

  boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_17;
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.efi.canTouchEfiVariables = true;

  environment.etc."iproute2/rt_tables.d/wg.conf".text = ''
    200 wg_table
  '';
  networking = {
    hostId = config.settings.hw.hostId;
    hostName = config.settings.hw.hostName;
    interfaces.wlp194s0.useDHCP = true;

    wireless = {
      enable = true; # Enables wireless support via wpa_supplicant.
      interfaces = [ "wlp194s0" ];
      networks = (lib.mapAttrs (name: value: { pskRaw = "${value}"; })
        config.settings.hw.wifi); # //
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

      peers = lib.mapAttrsToList (client: clientAttrs: {
        publicKey = clientAttrs.publicKey;
        allowedIPs = clientAttrs.allowedIPs;
        endpoint = clientAttrs.endpoint;
        persistentKeepalive = 25;
      }) config.settings.hw.wg.peers;
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
    gcr
    fprintd
    polkit_gnome
    tailscale
    dmidecode
    libva-utils
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
  users.users."${config.settings.usr.name}" = {
    extraGroups = [ "trezord" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJr0kbjhI/GRS7eAy9CaJJzxELhGgOzZTWOOzKUpgCAO"
    ];
  };

  services.resolved.enable = true;
  services.resolved.extraConfig = ''
    [Resolve]
    DNS=${lib.concatStringsSep " " config.settings.hw.wg.dns}
    Domains=~casa
  '';

  services.logind.settings.Login.HandlePowerKey = "suspend";

  services.udev.packages =
    [ pkgs.chrysalis pkgs.trezor-udev-rules pkgs.openocd ];
  services.udev.extraRules = ''
    # saleae logic analyser
    SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="21a9", ATTR{idProduct}=="1001", MODE="0666"
  '';

  services.trezord.enable = true;
  services.tailscale.enable = true;
  services.openssh.enable = true;
  services.openssh.openFirewall = true;

  services.fwupd.enable = true;

  services.pipewire = {
    #package = unstable.pipewire;
    wireplumber.enable = true;
    wireplumber.extraConfig."10-bluez" = {
      "monitor.bluez.properties" = {
        "bluez5.enable-sbc-xq" = true;
        "bluez5.enable-msbc" = true;
        "bluez5.enable-hw-volume" = true;
        "bluez5.roles" = [ "hsp_hs" "hsp_ag" "hfp_hf" "hfp_ag" ];
      };
    };
  };

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
  services.ollama = {
    enable = false;
    #acceleration = "rocm";
  };

  services.open-webui = {
    enable = false;
    port = 11111;
    environment = {
      ANONYMIZED_TELEMETRY = "False";
      DO_NOT_TRACK = "True";
      SCARF_NO_ANALYTICS = "True";
      OLLAMA_API_BASE_URL = "http://127.0.0.1:11434";
      WEBUI_AUTH = "False";

      ENABLE_RAG_WEB_SEARCH = "True";
      RAG_WEB_SEARCH_ENGINE = "duckduckgo";
      RAG_WEB_SEARCH_RESULT_COUNT = "3";
      RAG_WEB_SEARCH_CONCURRENT_REQUESTS = "10";
    };
  };
  services.dbus.packages = [ pkgs.gcr ];
  services.fprintd.enable = true;

  security.pam.services.swaylock.fprintAuth = true;
  security.pam.services.sudo.fprintAuth = true;
  security.pam.services.polkit-1.fprintAuth = true;
  security.pam.services.sddm.fprintAuth = true;

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
