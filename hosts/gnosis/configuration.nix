# gnosis host specific configuration
{ config, pkgs, ... }:
#let
#  nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
#    export __NV_PRIME_RENDER_OFFLOAD=1
#    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
#    export __GLX_VENDOR_LIBRARY_NAME=nvidia
#    export __VK_LAYER_NV_optimus=NVIDIA_only
#    exec -a "$0" "$@"
#  '';
#in
{
  settings = import ./vars.nix;

  imports = [
    ../../nixos/base.nix
    ../../nixos/workstation.nix
    ../../modules/settings.nix
    ./hardware-configuration.nix
  ];
  nix.package = pkgs.nixFlakes;

  nix.extraOptions = ''
    keep-outputs = true
    keep-derivations = true
    experimental-features = nix-command flakes
  '';
  nixpkgs.overlays = [ (import ../../overlays) ];

  networking.hostId = config.settings.hw.hostId;
  networking.hostName = config.settings.hw.hostName;

  #virtualisation.virtualbox.host.enableExtensionPack = true;
  boot.kernel.sysctl."net.ipv6.conf.wlp59s0.disable_ipv6" = true;
  networking.dhcpcd.wait = "background";

  networking.interfaces.wlp59s0.useDHCP = true;

  networking.hosts = { "192.168.56.11" = [ "local-puppet-server-001.localdomain puppet" ]; };
  networking.wireless = {
    enable = true;  # Enables wireless support via wpa_supplicant.
    interfaces = ["wlp59s0"];
    networks = {
      Arubaruba = {
        pskRaw = "f8152f56f0c16ecd4d4cf5456200ac7221d5b460b5931c0a72e1c17fbbc25462";
      };
      internet-only = {
        psk = "KlantVanDeToekomst!";
      };
      Interpol = {
        pskRaw = "359f63d7f718954e1e1feb4e850e70c6a04f775a408617445d2c1696742d1b82";
      };
      StrangerDanger = {
        psk = "Stuckintheupsidedown?";
      };
    };
    extraConfig = ''
      ctrl_interface=/run/wpa_supplicant
      ctrl_interface_group=wheel
    '';
  };
  environment.systemPackages = with pkgs; [
    docker-compose
    clamav
  ];

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  hardware.video.hidpi.enable = true;
#  hardware.nvidia.prime = {
#    offload.enable = true;
#
#    # Bus ID of the Intel GPU. You can find it using lspci, either under 3D or VGA
#    intelBusId = "PCI:0:2:0";
#    # Bus ID of the NVIDIA GPU. You can find it using lspci, either under 3D or VGA
#    nvidiaBusId = "PCI:1:0:0";
#  };

  # Kerberos
  krb5 = {
    enable = true;
    libdefaults = {
      default_realm = "BOLCOM.NET";
      default = "BOLCOM.NET";
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
      "BOLCOM.NET" = {
         admin_server = "shd-kadmin-vip.bolcom.net";
         default_domain = "bolcom.net";
      };
    };
    domain_realm = {
      ".bolcom.net" = "BOLCOM.NET";
      "bolcom.net" = "BOLCOM.NET";
      ".local.nl.bol.com" = "BOLCOM.NET";
      "local.nl.bol.com" = "BOLCOM.NET";
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
  services.openssh.enable = false;
  # services.openssh.permitRootLogin = "yes";
  # Open ports in the firewall.
  #networking.firewall.allowedTCPPorts = [ 8033 ];
  services.fwupd.enable = true;

  services.clamav = {
    daemon.enable = true;
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

