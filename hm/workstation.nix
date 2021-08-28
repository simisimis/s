# hm workstation
{ nixosConfig, config, pkgs, autoPatchelfHook, ... }:
let
  unstable = import <nixos-unstable> { config.allowUnfree = true; };
in
{
  nixpkgs.config.allowUnfree = true;
  home.packages = with pkgs; [
    #utils
    arandr
    pavucontrol
    gopass
    freerdp
    speedcrunch
    scrot
    flameshot
    xclip
    termite
    filezilla

    #web
    firefox
    chromium

    #media
    gthumb
    digikam
    feh
    gimp
    obs-studio
    ffmpeg-full
    mpv-unwrapped
    spotify
    calibre

    wally-cli

    #elf shennanigens
    patchelf
    nix-index
    binutils
    gnumake
    gcc

    #dev
    unstable.go unstable.golint dep
    exercism

    unstable.prusa-slicer
  ];

  programs.vscode = {
    enable = true;
    package = unstable.vscode-with-extensions // { pname = "vscode"; };
    #extensions = [
    #  vscode-extensions.ms-vscode.Go
    #];
  };
  programs.zathura.enable = true;
  programs.rofi.enable = true;
  programs.rofi.theme = "Pop-Dark.rasi";
  programs.termite = {
    enable = true;
    font = "Meslo LG S DZ 12";
    backgroundColor = "rgba(63, 63, 63, 0.5)";
    scrollbackLines = 10000;
    foregroundColor = "dedede";
    foregroundBoldColor = "dedede";
    cursorColor = "#6f6f6f";
    colorsExtra = ''
      # black
      color0  = #2e3436
      color8  = #555753

      # red
      color1  = #fc3e3e
      color9  = #f06464

      # green
      color2  = #66b31e`
      color10 = #8ae234

      # yellow
      color3  = #f6d922
      color11 = #fce94f

      # blue
      color4  = #5183c4
      color12 = #729fcf

      # magenta
      color5  = #c36ccf
      color13 = #c164b6

      # cyan
      color6  = #19a5a7
      color14 = #429bf1

      # white
      color7  = #d3d7cf
      color15 = #eeeeec

    '';
  };
  # services
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    pinentryFlavor = "gtk2";
  };
  xdg = {
    configFile."obs-studio/plugins/obs-v4l2sink/bin/64bit/obs-v4l2sink.so".source =
    "${pkgs.obs-v4l2sink}/share/obs/obs-plugins/v4l2sink/bin/64bit/v4l2sink.so";
    configFile."mimeapps.list".force = true;
    mimeApps = {
      enable = true;
      associations.added = {
        "x-scheme-handler/magnet"="userapp-transmission-gtk-XEE0Y0.desktop";
      };
      defaultApplications = {
        "text/html" = "browser";
        "x-scheme-handler/http"="browser.desktop";
        "x-scheme-handler/https"="browser.desktop";
        "x-scheme-handler/about"="browser.desktop";
        "x-scheme-handler/unknown"="browser.desktop";
        "x-scheme-handler/magnet"="userapp-transmission-gtk-XEE0Y0.desktop";
        "x-scheme-handler/msteams"="teams.desktop";
      };
    };
  };
    programs.ssh = {
    enable = true;
    matchBlocks = {
      "192.168.178.100" = {
        user = "simas";
        identityFile = nixosConfig.settings.usr.ssh.backute.identityFile;
      };
      "github.com" = {
        user = "git";
        identityFile = nixosConfig.settings.usr.ssh.github.identityFile;
        extraOptions = { 
          AddKeysToAgent = "yes";
          PubKeyAuthentication = "yes";
        };
      };
    };
  };
  home.file.".config/awesome".source = builtins.fetchGit {
    url = "ssh://git@git.narbuto.lt:2203/simas/awesome.git";
    ref = "master";
  };
  home.file."bin".source = builtins.fetchGit {
    url = "ssh://git@git.narbuto.lt:2203/simas/binfiles.git";
    ref = "master";
  };
  home.file.".xinitrc".text = ''
  if test -z "$DBUS_SESSION_BUS_ADDRESS"; then
    eval $(dbus-launch --exit-with-session --sh-syntax)
  fi
  systemctl --user import-environment DISPLAY XAUTHORITY

  if command -v dbus-update-activation-environment >/dev/null 2>&1; then
    dbus-update-activation-environment DISPLAY XAUTHORITY
  fi
  exec awesome
  '';

}
