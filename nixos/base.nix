{ config, pkgs, agenix, ... }:
{
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.efi.canTouchEfiVariables = true;

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.firewall.enable = true;
  #networking.firewall.allowedTCPPorts = [ 8384 22000 ];
  #networking.firewall.allowedUDPPorts = [ 22000 21027 ];

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Enable sound.
  sound.enable = false;
  hardware.pulseaudio.enable = false;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.syncthing = {
    enable = true;
    user = config.settings.usr.name;
    overrideFolders = true;
    devices = {
      "gnosis" = { id = "CEF2GB3-OIANJ7X-AGC3CUN-ITGKOXX-TN3N2NI-DOV3ZGP-YLRCUJV-BTMMEAB"; };
      "backute" = { id = "SQW6JN7-ZEXNTZF-MZNPYDB-UW46K4R-MCVZORG-LFYLFLF-SZW3U3N-OVNTYAH"; };
      "simsung" = { id = "7L3QGPS-ZTFMSBX-2RJC754-STXLMZ5-ASVZKAR-BLO4FYR-ED3LGEL-CDY3IAJ"; };
      "simonster" = { id = "RTHCXR3-OO65GDV-UTUY5ON-AD33JSB-3KXC4DK-SBVQCQV-YX7W47M-P3WVPAN"; };
    };
    folders = {
      "papyrus" = {        # Name of folder in Syncthing, also the folder ID
        devices = [ "backute" "gnosis" "simsung" "simonster" ];      # Which devices to share the folder with
      };
    };
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
      extraGroups = [ "wheel" "audio" "plugdev" "docker" "vboxusers" "dialout" ];
      useDefaultShell = true;
      hashedPassword = config.settings.usr.pwdHash;
    };
  };

  fonts.fonts = with pkgs; [
    noto-fonts
    source-code-pro
    meslo-lg
    (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #system
    xf86_input_wacom
    wacomtablet
    libwacom
    libinput
    wev
    sshfs
    lsof
    wget curl dig
    neovim
    git tig
    gnupg
    agenix.defaultPackage.x86_64-linux
    inetutils
    pciutils

    #utils
    zip
    unzip
    ranger
    fzf
    jq
    ripgrep
    fd
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

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

}
