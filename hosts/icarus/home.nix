# host specific home manager configuration
{ config, pkgs, unstable, ... }: {
  settings = import ./vars.nix;
  nixpkgs.overlays = [ (import ../../overlays) ];

  programs.home-manager.enable = true;
  programs.diff-so-fancy.enable = true;
  programs.git = {
    signing.key = "FDD52A4151D7E8E4";
    settings = {
      user.email = config.settings.usr.email;
      user.name = config.settings.usr.fullName;
      github.user = config.settings.usr.username;
      alias = {
        hist =
          "log --color --pretty=format:'%Cred%h%Creset - %s %C(yellow)%d%Creset %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
      };
      fetch.prune = true;
      fetch.pruneTags = true;
    };
  };
  home.username = config.settings.usr.name;
  home.homeDirectory = "/home/${config.settings.usr.name}";

  services.kanshi.enable = true;
  services.kanshi.systemdTarget = "hyprland-session.target";
  services.kanshi.settings = [
    {
      profile.name = "singleAR";
      profile.outputs = [
        {
          criteria = "Nreal XREAL One Pro Unknown";
          position = "0,0";
          status = "enable";
          scale = 1.0;
          mode = "1920x1080@120Hz";
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
      profile.outputs = [{
        criteria = "eDP-1";
        position = "0,0";
        status = "enable";
        scale = 1.0;
      }];
    }
    {
      profile.name = "office";
      profile.outputs = [
        {
          criteria = "Samsung Electric Company S32B80P HNBWA00004";
          position = "0,0";
          scale = 1.5;
          mode = "3840x2160@60.00Hz";
          status = "enable";
        }
        {
          criteria = "eDP-1";
          status = "disable";
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
    blender
    kicad
    gsettings-desktop-schemas
    arduino-ide
    libGL
    subsurface
    mtr
    bambu-studio
    nodejs-slim_26
    just
    pre-commit
    unstable.prusa-slicer
    grpcurl
    xh
    dust
    actionlint
    tmate
    gh
    graphviz
    exiftool
    dust
    procs
    eza
    tldr
    darktable
    unstable.codex
    unstable.pi-coding-agent
    unstable.rtk
    meld

    #system
    cifs-utils
    rclone
    restic

    #dev
    helm-docs
    kustomize
    ec2-api-tools
    awscli2
    #eksctl
    #eks-node-viewer
    #ssm-session-manager-plugin
    kubernetes-helm
    kubecolor
    krew
    unstable.helmfile
    ksd
    #(google-cloud-sdk.withExtraComponents
    #  [ google-cloud-sdk.components.gke-gcloud-auth-plugin ])
    doctl
    kubectx
    kubectl
    k9s
    stern
    unstable.terraform

    #saleae-logic
    dioxus-cli
    radicle-node
    jdk25

    #web
    unstable.ledger-live-desktop

    #scripts
    (writeShellScriptBin "brightness"
      (builtins.readFile ../../scripts/brightness))
    (writeShellScriptBin "wpa-add"
      (builtins.readFile ../../scripts/wpa-add-network))
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
    extraConfig = ''
      local os = require "os";
      return {
        default_ssh_auth_sock = os.getenv 'SSH_AUTH_SOCK',
        enable_kitty_keyboard = true,
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
    extraOptionOverrides = { CanonicalizeHostname = "yes"; };
    settings = {
      "*.zeko.io" = {
        User = "nixos";
        IdentityFile = config.settings.usr.ssh.hz.identityFile;
        port = 2203;
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
  programs.zsh = {
    cdpath = [ "~/dev" ];
    initContent = ''
      source <(kubectl completion zsh)
      export JAVA_HOME="${pkgs.jdk25}"
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
    plugins = [{
      name = "fzf-tab";
      src = pkgs.fetchFromGitHub {
        owner = "Aloxaf";
        repo = "fzf-tab";
        rev = "v1.1.1";
        sha256 = "sha256-0/YOL1/G2SWncbLNaclSYUz7VyfWu+OB8TYJYm4NYkM=";
      };
    }];
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
        text = [{
          run = ''hx "$@" '';
          for = "linux";
        }];
        zathura = [{
          run = ''zathura "$@"'';
          block = true;
        }];
        image = [{
          run = ''imv "$@" '';
          block = true;
          for = "linux";
        }];
        video = [{
          run = ''mpv "$@" '';
          block = true;
          for = "linux";
        }];
        reveal = [{
          run = ''${pkgs.exiftool}/bin/exiftool "$1";'';
          block = true;
        }];
      };
    };
  };
  programs.yt-dlp.enable = true;
  programs.obs-studio.enable = true;
}
