# lavirinthos specific home manager configuration
{ config, pkgs, nixpkgs-unstable, lib, ... }:
let
  unstable = import nixpkgs-unstable {
    system = "x86_64-linux";
    config = { allowUnfree = true; };
  };
  wallpaper = ./wallpaper.jpg;
in
{
  settings = import ./vars.nix;
  # import overlays
  nixpkgs.overlays = [ (import ../../overlays) ];
  programs.home-manager.enable = true;
  programs.git = {
    userName = config.settings.usr.fullName;
    userEmail = config.settings.usr.email;
    diff-so-fancy.enable = true;
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
      modifier = "Mod4";
      input = {
        "type:keyboard" = {
          xkb_layout = "us,lt,gr";
          xkb_options = "ctrl:nocaps,grp:ctrl_space_toggle";
        };
      };
      terminal = "wezterm";
      output."*".bg = "${wallpaper} fit";
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
  wayland.windowManager.hyprland = {
    enable = true;

    settings = {
      exec-once = [ "waybar" "systemctl --user restart kanshi" ];


      general = {
        gaps_in = 1;
        gaps_out = 2;
      };
      # ********** Key Bindings **********
      # See https://wiki.hyprland.org/Configuring/Binds/ for more.

      "$launcher" = "wofi --show run";
      "$browser" = "firefox";
      #"$terminal" = "alacritty";
      "$terminal" = "wezterm";

      # https://wiki.hyprland.org/Configuring/Variables/#input
      input = {
        kb_layout = "us,lt,gr";
        kb_options = "ctrl:nocaps,grp:ctrl_space_toggle";
      };

      bind = [
        # Launch programs.
        "SUPER, D, exec, $launcher"

        "SUPER, Return, exec, $terminal"
        # Quit current program.
        "SUPER SHIFT, Q, killactive"
        # Toggle fullscreen.
        "SUPER, F, fullscreen"
        # Focus windows.
        "SUPER, up, movefocus, u"
        "SUPER, down, movefocus, d"
        "SUPER, left, movefocus, l"
        "SUPER, right, movefocus, r"
        # Focus workspace by number.
        "SUPER, 1, workspace, 1"
        "SUPER, 2, workspace, 2"
        "SUPER, 3, workspace, 3"
        "SUPER, 4, workspace, 4"
        "SUPER, 5, workspace, 5"
        "SUPER, 6, workspace, 6"
        "SUPER, 7, workspace, 7"
        "SUPER, 8, workspace, 8"
        # Focus prev/next workspace.
        "CTRL SUPER, left, workspace, r-1"
        "CTRL SUPER, right, workspace, r+1"
        # Send window to the given desktop.
        "SUPER SHIFT, 1, movetoworkspace, 1"
        "SUPER SHIFT, 2, movetoworkspace, 2"
        "SUPER SHIFT, 3, movetoworkspace, 3"
        "SUPER SHIFT, 4, movetoworkspace, 4"
        "SUPER SHIFT, 5, movetoworkspace, 5"
        "SUPER SHIFT, 6, movetoworkspace, 6"
        "SUPER SHIFT, 7, movetoworkspace, 7"
        "SUPER SHIFT, 8, movetoworkspace, 8"

        # Print screen
        "SUPER SHIFT, T, exec, trimgrim"
        # Insert emoji
        "SUPER SHIFT, B, exec, wofi-emoji"
        # Quit Hyprland.
        "SUPER SHIFT, C, exit"
      ];
      # Move/resize windows with super + drag
      bindm = [
        "SUPER, mouse:272, movewindow"
        "SUPER, mouse:273, resizewindow"
      ];


      # https://wiki.hyprland.org/Configuring/Variables/#misc
      misc = {
        force_default_wallpaper = 2;
      };
      # https://easings.net/#easeOutQuint
      bezier = "ease_out_quint, 0.22, 1, 0.36, 1";
      # Disable all animations, except for workspace switching.
      animation = [
        "workspaces, 1, 5, ease_out_quint, slide"
        "windows, 0"
        "layers, 0"
        "fade, 0"
        "border, 0"
        "borderangle, 0"
      ];
    };
  };
  services.kanshi.enable = true;
  services.kanshi.settings = [
    {
      profile.name = "singleAR";
      profile.outputs = [
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
    }
    {
      profile.name = "singleAR2";
      profile.outputs = [
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
    }
    {
      profile.name = "dual";
      profile.outputs = [
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
    }
    {
      profile.name = "dualwide";
      profile.outputs = [
        {
          criteria = "Dell Inc. DELL U4025QW FNHNF34";
          position = "0,0";
          scale = 2.0;
          mode = "5120x2160@60.000Hz";
          status = "enable";
        }
        {
          criteria = "eDP-1";
          status = "disable";
        }
      ];
    }
    {
      profile.name = "single";
      profile.outputs = [
        {
          criteria = "eDP-1";
          position = "0,0";
          status = "enable";
          scale = 1.0;
        }
      ];
    }
  ];
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
    arduino-ide
    kustomize
    libGL
    gping
    chromium
    #logseq
    subsurface
    mtr
    ansible
    bambu-studio
    nodejs-slim_20
    unstable.zed-editor
    just
    pre-commit
    ec2-api-tools
    unstable.prusa-slicer
    jira-cli-go
    grpcurl
    xh
    du-dust
    actionlint
    tmate
    gh
    #unstable.awscli2
    awscli2
    eksctl
    eks-node-viewer
    kubernetes-helm
    kubecolor
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
    dioxus-cli

    #web
    unstable.ledger-live-desktop

  ];


  programs.wezterm = {
    enable = true;
    colorSchemes = {
      simColors = {
        ansi = [
          "#2e3436"
          "#fc3e3e"
          "#66b31e"
          "#f6d922"
          "#5183c4"
          "#c36ccf"
          "#19a5a7"
          "#d3d7cf"
        ];
        brights = [
          "#555753"
          "#f06464"
          "#8ae234"
          "#fce94f"
          "#729fcf"
          "#c164b6"
          "#429bf1"
          "#eeeeec"
        ];
        background = "#3f3f3f";
        foreground = "#dedede";
        cursor_bg = "#949cbb";
        cursor_border = "#949cbb";
        cursor_fg = "#303446";
        selection_bg = "#737994";
        selection_fg = "#303446";
      };
    };
    extraConfig =
      ''
        return {
          enable_tab_bar = false,
          harfbuzz_features = {"calt=0", "cv01", "cv02", "cv04", "ss01", "ss03", "ss04", "cv31", "cv08", "cv30", "cv27"},
          font = wezterm.font('Fira Code', { weight = 'Light'}),
          font_size = 12,
          color_scheme = "simColors",
          -- #Scrollback
          -- #scrollback_lines = 10000,

          -- Window
          window_padding = {
            left = 10,
            right = 10,
            top = 10,
            bottom = 10,
          },
        }
      '';
  };
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
    settings = {
      anchor = "bottom-right";
      font = "Fira Code 12";
      background-color = "#44485b";
      text-color = "#c0caf5";
      width = 350;
      margin = "0,20,20";
      padding = "10";
      border-size = 2;
      border-color = "#414868";
      border-radius = 5;
      default-timeout = 5000;
      group-by = "summary";
    };
  };

  programs.ssh = {
    extraOptionOverrides = {
      CanonicalizeHostname = "yes";
    };

    matchBlocks = {
      "*.hz.minaprotocol.network" = {
        user = "root";
        identityFile = config.settings.usr.ssh.hz.identityFile;
        extraOptions = {
          AddKeysToAgent = "yes";
          PubKeyAuthentication = "yes";
          ControlMaster = "auto";
          ControlPath = "~/.ssh/master-%r@%h:%p";
          ControlPersist = "600";
          StrictHostKeyChecking = "no";
          UserKnownHostsFile = "/dev/null";
        };
      };
    };
  };
  programs.zsh = {
    cdpath = [
      "~/dev"
    ];
    initContent = ''
      source <(kubectl completion zsh)
      export JAVA_HOME="${pkgs.jdk23}"
      export BW_SESSION="${config.settings.services.vaultwarden.sessionId}"
      #export JIRA_API_TOKEN=""
      #export AWS_PROFILE=""
      export LD_LIBRARY_PATH="${pkgs.libGL}/lib:/run/opengl-driver/lib"

      # make completion work with kubecolor
      compdef kubecolor=kubectl

      # todo () {
      #   local description="$*" # get all arguments
      #   jira issue create --template ~/.config/.jira/issue-template.yml \
      #     -a $(jira me) \
      #     -tTask \
      #     --custom team=4df12a6f-710c-4bc9-a8e9-a8a77b54567d \
      #     --component="DevOps" \
      #     --summary "$description" \
      #     --no-input
      #   ISSUE_ID=$(jira issue list -a $(jira me) --paginate 1 --no-headers --plain --columns id)
      #   jira issue move $ISSUE_ID "Selected for Development"
      #   jira open $ISSUE_ID
      # }
      # aws-portforward () {
      #   CLUSTER=$1
      #   HOST=$2
      #   LOCAL=$3
      #   PORT=$4

      #   NODEGROUP=$(aws eks list-nodegroups --cluster-name $CLUSTER --query 'nodegroups' --output text)
      #   SCALINGGROUP=$(aws eks describe-nodegroup --cluster-name $CLUSTER --nodegroup-name $NODEGROUP --query 'nodegroup.resources.autoScalingGroups[*].name' --output text)
      #   INSTANCEID=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names $SCALINGGROUP --query 'AutoScalingGroups[*].Instances[0].InstanceId' --output text)
      #   PARAMETERS=$(jq -n --arg port $PORT --arg host $HOST --arg local $LOCAL '{"portNumber":[$port],"localPortNumber":[$local],"host":[$host]}')

      #   aws ssm start-session --target $INSTANCEID --document-name AWS-StartPortForwardingSessionToRemoteHost --parameters "$PARAMETERS" 
      # }
    '';
    shellAliases = {
      kns = "kubens";
      kctx = "kubectx";
      kubectl = "kubecolor";
      k = "kubecolor";
    };
    plugins = [
      {
        name = "fzf-tab";
        src = pkgs.fetchFromGitHub {
          owner = "Aloxaf";
          repo = "fzf-tab";
          rev = "v1.1.1";
          sha256 = "sha256-0/YOL1/G2SWncbLNaclSYUz7VyfWu+OB8TYJYm4NYkM=";
        };
      }
    ];
  };
  programs.zoxide.enable = true;
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    package = unstable.yazi;
    settings = {
      open.rules = [
        {
          mime = "text/*";
          use = [ "edit" "reveal" ];
        }
        {
          mime = "image/*";
          use = [ "image" "reveal" ];
        }
        {
          mime = "video/*";
          use = [ "video" "reveal" ];
        }
        {
          mime = "application/json";
          use = [ "edit" "reveal" ];
        }
        {
          mime = "application/pdf";
          use = "zathura";
        }
        {
          mime = "*";
          use = [ "edit" "open" "reveal" ];
        }
      ];
      opener = {
        text = [
          {
            run = ''hx "$@" '';
            for = "linux";
          }
        ];
        zathura = [
          {
            run = ''zathura "$@"'';
            block = true;
          }
        ];
        image = [
          {
            run = ''imv "$@" '';
            block = true;
            for = "linux";
          }
        ];
        video = [
          {
            run = ''mpv "$@" '';
            block = true;
            for = "linux";
          }
        ];
        reveal = [
          {
            run = ''${pkgs.exiftool}/bin/exiftool "$1";'';
            block = true;
          }
        ];
      };
    };
  };
  programs.yt-dlp.enable = true;
}
