{ config, pkgs, unstable, ... }: {
  # Extra kernel modules
  # Register a v4l2loopback device at boot
  boot.kernelModules = [ "v4l2loopback" ];
  # Extra kernel modules
  boot.extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];

  services.pulseaudio.enable = false;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

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

    #fonts
    meslo-lg
    noto-fonts
  ]);
  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    autorun = false;
    videoDrivers = [ config.settings.hw.videoDrv ];
    displayManager.startx.enable = true;
    xkb.layout = "us";
    xkb.options = "terminate:ctrl_alt_bksp,ctrl:nocaps,eurosign:e";
    wacom.enable = false;
    #libinput.touchpad.tapping = false;
    windowManager.awesome.enable = true;
  };
  services.libinput.enable = true;

  # Virtualization
  virtualisation.virtualbox.host.enable = false;

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
}
