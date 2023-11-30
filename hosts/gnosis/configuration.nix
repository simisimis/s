# gnosis host specific configuration
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

  networking.hostId = config.settings.hw.hostId;
  networking.hostName = config.settings.hw.hostName;

  #virtualisation.virtualbox.host.enableExtensionPack = true;
  boot.kernel.sysctl."net.ipv6.conf.wlp59s0.disable_ipv6" = true;
  networking.dhcpcd.wait = "background";

  networking.interfaces.wlp59s0.useDHCP = true;

  networking.hosts = { "192.168.56.11" = [ "local-puppet-server-001.localdomain puppet" ]; };
  networking.wireless = {
    enable = false;  # Enables wireless support via wpa_supplicant.
    interfaces = ["wlp59s0"];
    extraConfig = ''
      ctrl_interface=/run/wpa_supplicant
      ctrl_interface_group=wheel
    '';
  };
  environment.systemPackages = with pkgs; [
    docker-compose
    clamav
    dmidecode
  ];

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  hardware.video.hidpi.enable = true;

  # Kerberos
  krb5 = {
    enable = true;
    libdefaults = {
      default_realm = "DOMAIN.NET";
      default = "DOMAIN.NET";
      forwardable = false;
      kdc_timesync = 1;
      ccache_type = 5;
      default_ccache_name = "KEYRING:persistent:%{uid}";
      proxiable = false;
      dns_lookup_kdc = true;
      dns_lookup_realm = true;
      ticket_lifetime = "12h";
    };
    realms = {
      "DOMAIN.NET" = {
         admin_server = "adm.domain.net";
         default_domain = "domain.net";
      };
    };
    domain_realm = {
      ".domain.net" = "DOMAIN.NET";
      "domain.net" = "DOMAIN.NET";
      ".local.domain.com" = "DOMAIN.NET";
      "local.domain.com" = "DOMAIN.NET";
    };
    extraConfig = "[login]\n  krb4_convert = true\n  krb4_get_tickets = false\n";
  };

  # Virtualization
  virtualisation.docker.enable = true;

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
  services.udev.extraRules = ''
  ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="intel_backlight", GROUP="wheel", MODE="0664"
  # saleae logic analyser
  SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="21a9", ATTR{idProduct}=="1001", MODE="0666"
  '';
  services.openssh.enable = true;
  services.openssh.openFirewall = false;
  services.fwupd.enable = true;

  services.clamav = {
    daemon.enable = true;
    daemon.settings = {
      OnAccessIncludePath = "/home/${config.settings.usr.name}";
    };
    updater.enable = true;
  };

  services.pipewire  = {
    media-session.config.bluez-monitor.rules = [
      {
        # Matches all cards
        matches = [ { "device.name" = "~bluez_card.*"; } ];
        actions = {
          "update-props" = {
            "bluez5.reconnect-profiles" = [ "hfp_hf" "hsp_hs" "a2dp_sink" ];
            # mSBC is not expected to work on all headset + adapter combinations.
            "bluez5.msbc-support" = true;
            # SBC-XQ is not expected to work on all headset + adapter combinations.
            "bluez5.sbc-xq-support" = true;
          };
        };
      }
      {
        matches = [
          # Matches all sources
          { "node.name" = "~bluez_input.*"; }
          # Matches all outputs
          { "node.name" = "~bluez_output.*"; }
        ];
        actions = {
          "node.pause-on-idle" = false;
        };
      }
    ];
  };

  services.syncthing = {
    # Folder for Syncthing's settings and keys
    configDir = "/home/${config.settings.usr.name}/${config.settings.services.syncthing.configDir}";
    settings = {
      folders = {
        "papyrus" = {
          path = "/home/${config.settings.usr.name}/${config.settings.services.syncthing.dataDir}";
        };
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

