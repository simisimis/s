# lavirinthos specific home manager configuration
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
    signing.key = "55887CDF19112610";
    extraConfig = {
      github.user = config.settings.usr.username;
      alias = {
        hist = "log --color --pretty=format:'%Cred%h%Creset - %s %C(yellow)%d%Creset %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
      };
      fetch.prune = true;
      fetch.pruneTags = true;
    };
  };
  home.username = config.settings.usr.name;
  home.homeDirectory = "/home/${config.settings.usr.name}";

  wayland.windowManager.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraConfig = ''
      exec_always "systemctl --user restart kanshi.service"
    '';
    config = {
      input = {
        "type:keyboard" = {
          xkb_layout = "us,lt,gr";
          xkb_options = "ctrl:nocaps,grp:ctrl_space_toggle";
        };
      };
      terminal = "alacritty";
      output = { "*" = { bg = "~/Pictures/owl_1080.jpg fit"; }; };
      gaps = {
        inner = 3;
        outer = 0;
        smartBorders = "off";
      };
      window = {
        titlebar = false;
        border = 0;
      };
      floating = {
        titlebar = false;
      };
      keybindings =
        let
          modifier = config.wayland.windowManager.sway.config.modifier;
        in
        lib.mkOptionDefault {
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
    singleAR = {
      outputs = [
        {
          criteria = "LBT Rokid Max Unknown";
          position = "0,0";
          status = "enable";
          scale = 1.0;
          mode = "1920x1080@60Hz";
        }
        {
          criteria = "eDP-1";
          status = "disable";
        }
        {
          criteria = "Dell Inc. DELL U2720Q F7MFTS2";
          status = "disable";
        }
      ];
    };
    singleAR2 = {
      outputs = [
        {
          criteria = "LBT Rokid Max Unknown";
          position = "0,0";
          status = "enable";
          scale = 1.0;
          mode = "1920x1080@60Hz";
        }
        {
          criteria = "eDP-1";
          status = "disable";
        }
      ];
    };
    dual = {
      outputs = [
        {
          criteria = "Dell Inc. DELL U2720Q F7MFTS2";
          position = "0,0";
          scale = 2.0;
          mode = "3840x2160@60Hz";
          status = "enable";
        }
        {
          criteria = "eDP-1";
          status = "disable";
        }
      ];
    };
    single = {
      outputs = [
        {
          criteria = "eDP-1";
          position = "0,0";
          status = "enable";
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
  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    pre-commit
    ec2-api-tools
    prusa-slicer
    jira-cli-go
    grpcurl
    actionlint
    tmate
    gh
    unstable.awscli2
    eksctl
    kubernetes-helm
    krew
    unstable.helmfile
    ksd
    ssm-session-manager-plugin
    postgresql
    dhall-json
    minikube
    graphviz
    exiftool
    du-dust
    procs
    eza
    tldr
    darktable
    # start wayland
    swaylock
    swayidle
    wl-clipboard
    ethtool
    mako # notification daemon
    wofi
    wofi-emoji
    wtype
    waybar
    slurp
    grim
    brightnessctl
    pamixer
    wdisplays

    fantasque-sans-mono
    font-awesome_5
    roboto-mono
    (nerdfonts.override { fonts = [ "Mononoki" "FiraCode" ]; })
    material-icons
    gnome.adwaita-icon-theme
    libappindicator
    # end wayland

    #system
    cifs-utils
    rclone
    restic

    #dev
    jdk11
    (google-cloud-sdk.withExtraComponents [ google-cloud-sdk.components.gke-gcloud-auth-plugin ])
    kubectx
    kubectl
    k9s
    stern
    unstable.terraform
    saleae-logic
    jetbrains.idea-community
    lens # kubernetes ide
    dioxus-cli

    #web
    unstable.ledger-live-desktop

  ];

  programs.alacritty = {
    enable = true;
    settings = {
      font = {
        size = 12;

        normal = {
          family = "Fira Code";
          style = "Regular";
        };
        bold = {
          family = "Fira Code";
          style = "Bold";
        };
        italic = {
          family = "Fira Code";
          style = "Italic";
        };
        bold_italic = {
          family = "Fira Code";
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
      window.opacity = 1;
    };
  };

  services.mako = {
    enable = true;
    anchor = "bottom-right";
    font = "JetBrainsMono Nerd Font 12";
    backgroundColor = "#44485b";
    textColor = "#c0caf5";
    width = 350;
    margin = "0,20,20";
    padding = "10";
    borderSize = 2;
    borderColor = "#414868";
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
    };

    extraConfig = ''
      AddKeysToAgent yes
    '';
    matchBlocks = {
      "192.168.178.73" = {
        user = "simas";
        identityFile = config.settings.usr.ssh.siMONSTER.identityFile;
      };
    };
  };
  programs.zsh = {
    cdpath = [
      "~/dev/MinaFoundation"
    ];
    initExtra = ''
      export JAVA_HOME="${pkgs.jdk11}"
      export BW_SESSION="${config.settings.services.bitwarden.sessionId}"
      export JIRA_API_TOKEN="${config.settings.services.jira.apiToken}"
      export AWS_PROFILE="mina"
      todo () {
        local description="$*" # get all arguments
        jira issue create --template ~/.config/.jira/issue-template.yml \
          -a $(jira me) \
          -tTask \
          --custom team=4df12a6f-710c-4bc9-a8e9-a8a77b54567d \
          --component="DevOps" \
          --summary "$description" \
          --no-input
        issueID=$(jira issue list --plain --no-headers --columns key -q "summary ~ '$description'")
        sprintID=$(jira sprint list --plain --table --columns id,name --state=active --no-headers | grep DevOps |cut -f1)
        jira sprint add $sprintID $issueID
      }
    '';
    shellAliases = {
      kns = "kubens";
      kctx = "kubectx";
      k = "kubectl";
    };
  };
}
