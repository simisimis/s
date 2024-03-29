# gnosis specific home manager configuration
{ config, pkgs, nixpkgs-unstable, lib, ... }:
let
  unstable = import nixpkgs-unstable {
    system = "x86_64-linux";
    config = { allowUnfree = true; };
  };
in
{
  settings = import ./vars.nix;
  # import overlays
  nixpkgs.overlays = [ (import ../../overlays) ];
  programs.home-manager.enable = true;
  programs.git = {
    userName = config.settings.usr.fullName;
    userEmail = config.settings.usr.email;
    extraConfig = {
      github.user = config.settings.usr.username;
      alias = {
        hist = "log --color --pretty=format:'%Cred%h%Creset - %s %C(yellow)%d%Creset %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
      };
    };
  };
  home.username = config.settings.usr.name;
  home.homeDirectory = "/home/${config.settings.usr.name}";

  wayland.windowManager.sway = {
    enable = true;
    wrapperFeatures.gtk = true ;
    extraConfig = ''
      exec_always "systemctl --user restart kanshi.service"
    '';
    config = {
      input = {
        "type:keyboard" = {
          xkb_layout = "us,lt";
          xkb_options = "ctrl:nocaps,grp:win_space_toggle";
        };
      };
      terminal = "alacritty";
      output = { "*" = { bg = "~/Pictures/owl_1080.jpg fit"; } ; };
      gaps = {
        inner = 3;
        outer = 0;
        smartBorders = "off";
      };
      window = {
        border = 0;
      };
      keybindings = let
        modifier = config.wayland.windowManager.sway.config.modifier;
        in lib.mkOptionDefault {
          #"${modifier}+Return" = "exec ${pkgs.termite}/bin/termite";
          "${modifier}+g" = "move workspace to output left";
          "${modifier}+b" = "move workspace to output up";
          "${modifier}+Shift+t" = "exec trimgrim";
          "${modifier}+Shift+p" = "exec wofipass";
          "${modifier}+Shift+b" = "exec wofi-emoji";
          "${modifier}+Shift+q" = "kill";
          "${modifier}+Shift+l" = "exec swaylock -f -i ~/Pictures/texture1_1.jpg -t";
          "${modifier}+d" = "exec ${pkgs.wofi}/bin/wofi --show run | ${pkgs.findutils}/bin/xargs swaymsg exec --";
          "XF86AudioRaiseVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ +5%";
          "XF86AudioLowerVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ -5%";
          "XF86AudioMute" = "exec pactl set-sink-mute @DEFAULT_SINK@ toggle";
          "XF86AudioMicMute" = "exec pactl set-source-mute @DEFAULT_SOURCE@ toggle";
          "XF86MonBrightnessDown" = "exec brightnessctl set 5%-";
          "XF86MonBrightnessUp" = "exec brightnessctl set +5%";
          "XF86AudioPlay" = "exec playerctl play-pause";
          "XF86AudioNext" = "exec playerctl next";
          "XF86AudioPrev" = "exec playerctl previous";
        }; 
      bars = [{
        statusCommand = "-";
        command = "waybar";
      }];
    };
  };
  services.kanshi.enable = true;
  services.kanshi.profiles = {
    home = {
      outputs = [
        {
          criteria = "eDP-1";
          position = "0,620";
          scale = 2.0;
        }
        {
          criteria = "DP-3";
          position = "1920,0";
          scale = 1.0;
        }
      ];
    };
    work = {
      outputs = [
        {
          criteria = "eDP-1";
          position = "0,980";
          scale = 2.0;
        }
        {
          criteria = "DP-1";
          position = "1920,620";
          scale = 1.0;
        }
      ];
    };
  };
  services = {
    gpg-agent = {
      defaultCacheTtl = 86400;
      maxCacheTtl = 86400;
      maxCacheTtlSsh = 86400;
      defaultCacheTtlSsh = 86400;
    };
  };
  
  home.packages = with pkgs; [
    exiftool
    du-dust
    procs
    eza
    tldr
    # start wayland
    swaylock
    swayidle
    wl-clipboard
    ethtool
    mako # notification daemon
    wofi
    wofi-emoji
    waybar
    slurp
    grim
    brightnessctl
    pamixer
    wdisplays

    fantasque-sans-mono
    font-awesome_5
    roboto-mono
    (nerdfonts.override { fonts = [ "Mononoki" ]; })
    material-icons
    gnome.adwaita-icon-theme
    libappindicator
    # end wayland

    #system
    krb5
    cifs-utils
    openconnect
    rclone
    restic

    #dev
    jdk11
    hiera-eyaml
    ruby bundix puppet pdk
    google-cloud-sdk
    kubectx kubectl k9s stern
    unstable.terraform
    vagrant
    saleae-logic
    jetbrains.idea-community
    lens # kubernetes ide

    #web
    teams
    zoom-us
    unstable.rambox

    unstable.robo3t
    unstable.mongodb-compass
  ];

  programs.alacritty = {
    enable = true;
    settings = {
      font = {
        size = 12;

        normal = {
          family = "Meslo LG S DZ";
          style = "Regular";
        };
        bold = {
          family = "Meslo LG S DZ";
          style = "Bold";
        };
        italic = {
          family = "Meslo LG S DZ";
          style = "Italic";
        };
        bold_italic = {
          family = "Meslo LG S DZ";
          style = "Bold Italic";
        };
      };
      colors = {
        # Default colors
        primary = {
          background = "#3F3F3F";
          foreground = "#DEDEDE";
        };
        normal = {
          black = "#2e3436";
          red = "#fc3e3e";
          green = "#66b31e";
          yellow = "#f6d922";
          blue = "#5183c4";
          magenta = "#c36ccf";
          cyan = "#19a5a7";
          white = "#d3d7cf";
        };
        bright = {
          black = "#555753";
          red = "#f06464";
          green = "#8ae234";
          yellow = "#fce94f";
          blue = "#729fcf";
          magenta = "#c164b6";
          cyan = "#429bf1";
          white = "#eeeeec";
        };
      };
      window.opacity = 0.9;
    };
  };

  programs.mako = {
    enable = true;
    anchor = "bottom-right";
    font = "mononoki Nerd Font 10";
    backgroundColor = "#44485b";
    textColor = "#c0caf5";
    width = 350;
    margin = "0,20,20";
    padding = "10";
    borderSize = 2;
    borderColor="#414868";
    borderRadius = 5;
    defaultTimeout = 5000;
    groupBy = "summary";
    extraConfig = ''
    [grouped]
    format=<b>%s</b>\n%b
    '';
  };

  programs.ssh = {
    extraOptionOverrides = {
      CanonicalizeHostname = "yes";
      CanonicalDomains = "domain.net domain2.net";
    };

    extraConfig = ''
      UseRoaming no
      AddKeysToAgent yes
    '';
    matchBlocks = {
      "*.domain.com" = {
        user = config.settings.usr.name;
        extraOptions = {
          ServerAliveInterval = "120";
          SendEnv = "FANCYPROMPT";
          StrictHostKeyChecking = "no";
          GSSAPIAuthentication = "yes";
          GSSAPIDelegateCredentials = "yes";
        };
      };
    };
  };
  programs.zsh = {
    cdpath = [
      "~/vagrant"
    ];
    initExtra = ''
    export FANCYPROMPT="\[\033[38;5;202m\][\[\033[38;5;4m\]\t\[\033[38;5;202m\]] \[\033[38;5;3m\]\h \[\033[38;5;6m\]\W \[\033[38;5;41m\]≫\[\033[0m\] "
    export JAVA_HOME="${pkgs.jdk11}"
    '';
  };
}
