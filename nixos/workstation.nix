{ config, lib, pkgs, unstable, ... }:
let
  zfsCompatibleKernelPackages = lib.filterAttrs (
    name: kernelPackages:
    (builtins.match "linux_[0-9]+_[0-9]+" name) != null
    && (builtins.tryEval kernelPackages).success
    && (!kernelPackages.${config.boot.zfs.package.kernelModuleAttribute}.meta.broken)
  ) pkgs.linuxKernel.packages;
  latestKernelPackage = lib.last (
    lib.sort (a: b: (lib.versionOlder a.kernel.version b.kernel.version)) (
      builtins.attrValues zfsCompatibleKernelPackages
    )
  );
in
{
  boot.kernelPackages = latestKernelPackage;
  boot.zfs.package = pkgs.zfs_unstable;

  # Extra kernel modules
  # Register a v4l2loopback device at boot
  boot.kernelModules = [ "v4l2loopback" ];
  # Extra kernel modules
  boot.extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];

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

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  services.seatd.enable = true;
  programs.dconf.enable = true;

  services.pulseaudio.enable = false;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Previously implied by the X server module through services.graphical-desktop.
  fonts.enableDefaultPackages = true;
  fonts.packages = with pkgs; [
    noto-fonts
    meslo-lg
    fira-mono
    fira-code
    fira-code-symbols
    nerd-fonts.droid-sans-mono
  ];

  environment.systemPackages = with unstable; [
    linuxPackages.v4l2loopback
    chrysalis
  ] ++ (with pkgs; [
    mesa-demos
    libinput
    wev
    # Previously implied by the X server module through services.graphical-desktop.
    xdg-utils

    #fonts
    meslo-lg
    noto-fonts
  ]);
  services.libinput.enable = true;

  # Flatpak
  services.flatpak.enable = true;
  xdg = with unstable; {
    portal = {
      enable = true;
      extraPortals = [
        xdg-desktop-portal-wlr
        xdg-desktop-portal-hyprland
      ];
      configPackages = [
        xdg-desktop-portal-wlr
        xdg-desktop-portal-gtk
        xdg-desktop-portal-hyprland
      ];
    };
  };
  services.gnome.at-spi2-core.enable = true;

  # List services that you want to enable:
  services.udisks2.enable = true;
  services.udev.packages = [ unstable.chrysalis ];
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTR{idVendor}=="3297", ATTR{idProduct}=="1969",TAG+="uaccess"
  '';

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

  security.sudo.extraRules = [
    {
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
    }
  ];
}
