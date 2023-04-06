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
    layout = "us";
    xkbOptions = "altwin:swap_lalt_lwin,terminate:ctrl_alt_bksp,caps:none,eurosign:e";
    libinput.enable = true;
    wacom.enable = true;
    #libinput.touchpad.tapping = false;
    windowManager.awesome.enable = true;
  };

  # Virtualization
  virtualisation.virtualbox.host.enable = true;

  # Flatpak
  services.flatpak.enable = true;
  xdg = {
    portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-wlr
        xdg-desktop-portal-gtk
      ];
    };
  };

  # List services that you want to enable:
  services.udev.packages = [pkgs.chrysalis];
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTR{idVendor}=="3297", ATTR{idProduct}=="1969", GROUP="plugdev"
  '';
}
