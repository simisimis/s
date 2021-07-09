# epiphanis host specific configuration
{ config, pkgs, ... }:
{
  settings = import ./vars.nix;

  imports = [
    ../../nixos/base.nix
    ../../modules/settings.nix
    ./hardware-configuration.nix
  ];

  # import overlays
  nixpkgs.overlays = [ (import ../../overlays) ];

  home-manager.users."${config.settings.usr.name}" = (import ./home.nix) config; #{ inherit config pkgs; };

  networking.hostId = config.settings.hw.hostId;
  networking.hostName = config.settings.hw.hostName;
  networking.interfaces.enp5s0.useDHCP = true;

  virtualisation.virtualbox.host.enableExtensionPack = true;
  #  boot.kernelPackages = pkgs.linuxPackages_5_11;
  boot.kernel.sysctl."net.ipv6.conf.wlp2s0.disable_ipv6" = true;
  boot.kernel.sysctl."net.ipv6.conf.enp0s20f0u1u2u3.disable_ipv6" = true;
  networking.dhcpcd.wait = "background";
  networking.interfaces.enp0s31f6.useDHCP = true;
  networking.interfaces.enp0s20f0u1u2u3.useDHCP = true;
  networking.interfaces.wlp2s0.useDHCP = true;
  networking.hosts = { "192.168.56.11" = [ "local-puppet-server-001.localdomain puppet" ]; };
  networking.wireless = {
    enable = true;  # Enables wireless support via wpa_supplicant.
    interfaces = ["wlp2s0"];
    networks = {
      Arubaruba = {
        pskRaw = "f8152f56f0c16ecd4d4cf5456200ac7221d5b460b5931c0a72e1c17fbbc25462";
      };
      blan = {
        pskRaw = "4085063bc1b97f4766df7ec2ab68e9ccfe4f2319ba0e031fb83dde13013e93f9";
      };
      internet-only = {
        psk = "KlantVanDeToekomst!";
      };
    };
    extraConfig = ''
      ctrl_interface=/run/wpa_supplicant
      ctrl_interface_group=wheel
    '';
  };

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

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

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #    unstable.pipewire
    linuxPackages.v4l2loopback
  ];
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
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
  '';
  services.openssh.enable = false;
  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 8033 ];

  security.sudo.enable = true;
  security.sudo.extraRules = [{
    groups = [ "wheel" ];
    commands = [{
      command = "/run/current-system/sw/bin/openconnect";
      options = [ "NOPASSWD" ];
    }];
  }];
}

