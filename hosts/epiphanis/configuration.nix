# epiphanis host specific configuration
{ config, pkgs, ... }:
{
  settings = import ./vars.nix;

  imports = [
    ../../nixos/base.nix
    ../../modules/settings.nix
    ./hardware-configuration.nix
  ];
  nix.extraOptions = ''
    keep-outputs = true
    keep-derivations = true
  '';
  # import overlays
  nixpkgs.overlays = [ (import ../../overlays) ];
  home-manager.users."${config.settings.usr.name}".imports = [ 
    ./home.nix
    ../../hm/base.nix
    ../../hm/workstation.nix
  ];

  networking.hostId = config.settings.hw.hostId;
  networking.hostName = config.settings.hw.hostName;
  networking.interfaces.enp5s0.useDHCP = true;

  #virtualisation.virtualbox.host.enableExtensionPack = true;
  #  boot.kernelPackages = pkgs.linuxPackages_5_11;
  boot.kernel.sysctl."net.ipv6.conf.wlp2s0.disable_ipv6" = true;
  boot.kernel.sysctl."net.ipv6.conf.enp0s20f0u1u2u3.disable_ipv6" = true;
  networking.interfaces.enp0s31f6.useDHCP = true;
  networking.interfaces.enp0s20f0u1u2u3.useDHCP = true;
  networking.interfaces.wlp2s0.useDHCP = true;
  networking.hosts = { "192.168.56.11" = [ "local-puppet-server-001.localdomain puppet" ]; };
  networking.wireless = {
    enable = false;  # Enables wireless support via wpa_supplicant.
    interfaces = ["wlp2s0"];
  };

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

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

