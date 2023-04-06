{ config, nixpkgs-unstable, ... }:
let
  pkgs = import nixpkgs-unstable {
    system = "x86_64-linux";
    config = { allowUnfree = true; };
  };
in
{

  nix.package = pkgs.nixFlakes;

  nix.extraOptions = ''
    keep-outputs = true
    keep-derivations = true
    experimental-features = nix-command flakes
  '';

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.firewall.enable = true;
  #networking.firewall.allowedTCPPorts = [ 8384 22000 ];
  #networking.firewall.allowedUDPPorts = [ 22000 21027 ];

  # Set your time zone.
  time.timeZone = "Europe/Athens";

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
    user = config.settings.usr.name;
    overrideFolders = true;
    devices = {
      "backute" = { id = config.settings.services.syncthing.ids.backute; };
      "simsung" = { id = config.settings.services.syncthing.ids.simsung; };
      "simonster" = { id = config.settings.services.syncthing.ids.simonster; };
      "lavirinthos" = { id = config.settings.services.syncthing.ids.lavirinthos; };
    };
    folders = {
      "papyrus" = {        # Name of folder in Syncthing, also the folder ID
        devices = [ "backute" "simsung" "simonster" "lavirinthos"];      # Which devices to share the folder with
      };
    };
  };
  programs.zsh.enable = true;
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
    tcpdump
    #system
    glxinfo
    xf86_input_wacom
    wacomtablet
    libwacom
    libinput
    wev
    sshfs
    lsof
    wget curl dig
    neovim
    git tig git-crypt
    gnupg
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
  system.stateVersion = "22.11"; # Did you read the comment?

}
