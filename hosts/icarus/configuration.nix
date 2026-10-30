{
  config,
  lib,
  pkgs,
  unstable,
  ...
}:
let
  keys = import ../../modules/keys.nix;
in
{
  imports = [
    ./hardware-configuration.nix
    ./disko-config.nix
  ];
  nix.settings.access-tokens = [
    "github.com=${config.settings.platform.github.accessToken}"
  ];

  environment.etc."iproute2/rt_tables.d/wg.conf".text = ''
    200 wg_table
  '';
  networking = {
    interfaces.wlp194s0.useDHCP = true;
    interfaces.eth0.useDHCP = true;

    wireless = {
      enable = true; # Enables wireless support via wpa_supplicant.
      interfaces = [ "wlp194s0" ];
      networks = (lib.mapAttrs (name: value: { pskRaw = "${value}"; }) config.settings.hw.wifi) // {
        "SPACES" = {
          extraConfig = ''
            key_mgmt=NONE
          '';
        };
      };

      userControlled = true;
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
      postUp = lib.concatMapStringsSep "\n" (cidr: ''
        ip route add ${cidr} dev wg0 table wg_table
        ip rule add to ${cidr} table wg_table priority 100
      '') config.settings.hw.wg.ips;
      postDown = lib.concatMapStringsSep "\n" (cidr: ''
        ip rule del to ${cidr} table wg_table priority 100
        ip route del ${cidr} dev wg0 table wg_table
      '') config.settings.hw.wg.ips;
    };

    firewall = {
      enable = true;
      allowedUDPPorts = [
        config.services.tailscale.port
        51820
      ];
      allowedTCPPorts = [ ];
      checkReversePath = "loose";
    };

  };
  environment.systemPackages = with pkgs; [
    gcr
    fprintd
    polkit_gnome
    dmidecode
    libva-utils
    docker-compose
    chrysalis
    vulkan-tools
    unstable.llama-cpp-vulkan
  ];

  #hardware.video.hidpi.enable = true;
  hardware.ledger.enable = true;

  # Virtualization
  virtualisation.docker = {
    enable = true;
    storageDriver = "zfs";
  };
  users.users."${config.settings.usr.name}" = {
    extraGroups = [
      "trezord"
      "seat"
      "wpa_supplicant"
    ];
  };

  services.resolved = {
    enable = true;
    settings.Resolve = {
      DNS = config.settings.hw.wg.dns;
      Domains = [ "~casa" ];
    };
  };

  programs.nix-ld.enable = true;
  programs.niri.enable = true;
  services.logind.settings.Login.HandlePowerKey = "suspend";

  # Firmware emits a spurious power key press on resume; the monotonic sleep
  # pauses during suspend, so the inhibitor covers the first seconds awake.
  systemd.services.power-key-debounce = {
    description = "Ignore the power key for a few seconds around suspend";
    before = [ "sleep.target" ];
    wantedBy = [ "sleep.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = ''
        ${pkgs.systemd}/bin/systemd-inhibit --what=handle-power-key --mode=block \
          --who=power-key-debounce --why="ignore spurious power key press on resume" \
          ${pkgs.coreutils}/bin/sleep 10
      '';
    };
  };

  services.udev.packages = [
    pkgs.chrysalis
    pkgs.trezor-udev-rules
  ];

  services.trezord.enable = true;
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
        "bluez5.roles" = [
          "a2dp_sink"
          "a2dp_source"
          "hsp_hs"
          "hsp_ag"
          "hfp_hf"
          "hfp_ag"
        ];
      };
    };
  };

  services.llama-cpp = {
    enable = false;
    model = "/home/${config.settings.usr.name}/dev/llm/Qwen3.5-9B-Q4_K_M.gguf";
    package = unstable.llama-cpp-vulkan;
  };

  services.dbus.packages = [ pkgs.gcr ];
  services.fprintd.enable = true;

  # hyprlock drives fprintd itself; pam_fprintd would contend for the reader.
  security.pam.services.hyprlock.fprintAuth = false;
  security.pam.services.sudo.fprintAuth = true;
  security.pam.services.polkit-1.fprintAuth = true;
  security.pam.services.sddm.fprintAuth = true;

  security.sudo.enable = true;
}
