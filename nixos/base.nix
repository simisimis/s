# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
let
  unstable = import <nixos-unstable> { config.allowUnfree = true; };
in
{
  imports =
    [ # Include the results of the hardware scan.
      <home-manager/nixos>
#      <nixos-unstable/nixos/modules/services/desktops/pipewire/pipewire.nix>
#      <nixos-unstable/nixos/modules/services/desktops/pipewire/pipewire-media-session.nix>
    ];
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Extra kernel modules
  # Register a v4l2loopback device at boot
  boot.kernelModules = [
    "v4l2loopback"
  ];
  # Extra kernel modules
  boot.extraModulePackages = [
    config.boot.kernelPackages.v4l2loopback
  ];

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.firewall.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;
  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    autorun = false;
    videoDriver = "mesa";
    displayManager.startx.enable = true;
    layout = "us";
    xkbOptions = "altwin:swap_lalt_lwin,terminate:ctrl_alt_bksp,caps:none,eurosign:e";
    libinput.enable = true;
    wacom.enable = true;
    libinput.touchpad.tapping = false;
    windowManager.awesome.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users = {
    mutableUsers = false;
    defaultUserShell = pkgs.zsh;
    extraGroups.vboxusers.members = [ config.settings.usr.name ];
    users."${config.settings.usr.name}" = {
      createHome = true;
      home = "/home/${config.settings.usr.name}";
      isNormalUser = true;
      group = "users";
      extraGroups = [ "wheel" "audio" "plugdev" "docker" "vboxusers" ];
      useDefaultShell = true;
      hashedPassword = config.settings.usr.pwdHash;
    };
  };

  fonts.fonts = with pkgs; [
    noto-fonts
    source-code-pro
    meslo-lg
  ];

  # Virtualization
  virtualisation.virtualbox.host.enable = true;
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #system
    xf86_input_wacom
    sshfs
    lsof
    wget curl
    neovim
    git tig
    gnupg

    #utils
    unzip
    ranger
    fzf
    jq
    ripgrep
    tree

    linuxPackages.v4l2loopback

    #fonts
    source-code-pro
    meslo-lg
    noto-fonts
 
  ];

  environment.variables = { 
    EDITOR = "nvim";
    VISUAL = "nvim"; 
  };

  # nix pkgs
  nixpkgs.config.allowUnfree = true;

  nixpkgs.overlays = [
    (self: super: {
     neovim = super.neovim.override {
       viAlias = true;
       vimAlias = true;
     };
   })
  ];

  # Flatpak
  services.flatpak.enable = true;
  xdg.portal.enable = true;
  xdg.portal.gtkUsePortal = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  # List services that you want to enable:
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTR{idVendor}=="3297", ATTR{idProduct}=="1969", GROUP="plugdev"
  '';

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;


#####################################################
#  nixpkgs.config.pulseaudio = true;
#  disabledModules = [ "services/desktops/pipewire.nix" ];
#  Not strictly required but pipewire will use rtkit if it is present
#  security.rtkit.enable = true;
#  services.pipewire = {
#    enable = true;
#    package = unstable.pipewire;
#    # Compatibility shims, adjust according to your needs
#    pulse.enable = true;
#    alsa = {
#      enable = true;
#      support32Bit = true;
#    };
#    jack.enable = true;
#  };
#  services.pipewire.media-session = {
#    package = unstable.pipewire.mediaSession;
#  };
#############################################

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?

}

