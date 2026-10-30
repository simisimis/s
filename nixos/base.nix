{
  config,
  lib,
  pkgs,
  unstable,
  ...
}:
{

  nix.extraOptions = ''
    keep-outputs = false
    keep-derivations = false
    experimental-features = nix-command flakes
  '';

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.firewall.enable = lib.mkDefault true;
  networking.firewall.trustedInterfaces = [ "tailscale0" ];

  boot.loader.systemd-boot.enable = lib.mkDefault true;
  boot.loader.systemd-boot.configurationLimit = lib.mkDefault 5;
  boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;
  boot.zfs.forceImportRoot = lib.mkDefault false;

  services.openssh.enable = lib.mkDefault true;
  services.openssh.settings.PasswordAuthentication = lib.mkDefault false;
  services.tailscale.enable = lib.mkDefault true;

  # Set your time zone.
  time.timeZone = "Europe/Athens";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  services.syncthing = {
    overrideFolders = true;
    settings = {

      devices = (lib.mapAttrs (name: value: { id = "${value}"; }) config.settings.services.syncthing.ids);
      folders = {
        "papyrus" = {
          # Name of folder in Syncthing, also the folder ID
          devices = lib.attrNames config.settings.services.syncthing.ids;
        };
      };
    };
  };
  programs.zsh.enable = true;
  users = {
    mutableUsers = false;
    defaultUserShell = pkgs.zsh;
    users."${config.settings.usr.name}" = {
      createHome = true;
      home = "/home/${config.settings.usr.name}";
      isNormalUser = true;
      group = "users";
      extraGroups = [
        "wheel"
        "audio"
        "video"
        "docker"
        "input"
        "dialout"
      ];
      useDefaultShell = true;
      hashedPassword = config.settings.usr.pwdHash;
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    tcpdump
    #system
    sshfs
    lsof
    wget
    curl
    dig
    neovim
    helix
    git
    tig
    git-crypt
    gnupg
    inetutils
    pciutils
    pv
    home-manager
    tailscale

    #utils
    zip
    unzip
    fzf
    jq
    ripgrep
    fd
    tree
    unstable.procs
  ];

  environment.variables = {
    EDITOR = "hx";
    VISUAL = "hx";
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
  system.stateVersion = "26.05"; # Did you read the comment?

}
