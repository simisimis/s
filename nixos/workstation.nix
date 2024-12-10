{ config, nixpkgs-unstable, ... }:
let
  pkgs = import nixpkgs-unstable {
    system = "x86_64-linux";
    config = { allowUnfree = true; };
  };
in
{
  # Extra kernel modules
  # Register a v4l2loopback device at boot
  boot.kernelModules = [
    "v4l2loopback"
  ];
  # Extra kernel modules
  boot.extraModulePackages = [
    config.boot.kernelPackages.v4l2loopback
  ];

  environment.systemPackages = with pkgs; [
    linuxPackages.v4l2loopback
    chrysalis
  ];
  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    autorun = false;
    videoDriver = config.settings.hw.videoDrv;
    displayManager.startx.enable = true;
    xkb.layout = "us";
    xkb.options = "altwin:swap_lalt_lwin,terminate:ctrl_alt_bksp,caps:none,eurosign:e";
    wacom.enable = true;
    #libinput.touchpad.tapping = false;
    windowManager.awesome.enable = true;
  };
  services.libinput.enable = true;

  # Virtualization
  virtualisation.virtualbox.host.enable = true;

  # Flatpak
  services.flatpak.enable = true;
  xdg = with pkgs; {
    portal = {
      enable = true;
      extraPortals = [
        xdg-desktop-portal-wlr
        xdg-desktop-portal-gtk
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
  services.udev.packages = [ pkgs.chrysalis ];
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTR{idVendor}=="3297", ATTR{idProduct}=="1969",TAG+="uaccess"
  '';
}
