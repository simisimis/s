# host specific home manager configuration
{
  config,
  lib,
  pkgs,
  unstable,
  zen-browser,
  ...
}:
let
  # hyprlock blocks until unlocked.
  lockCmd = "${pkgs.procps}/bin/pidof hyprlock || ${pkgs.hyprlock}/bin/hyprlock &";
  niriMsg = "${pkgs.niri}/bin/niri msg action";
  brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl";
in
{
  services.kanshi.enable = true;
  # Manage outputs in both Hyprland and Niri sessions.
  services.kanshi.systemdTarget = "graphical-session.target";
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
      profile.outputs = [
        {
          criteria = "eDP-1";
          position = "0,0";
          status = "enable";
          scale = 1.0;
        }
      ];
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
  services.hypridle.enable = lib.mkForce false;

  programs.hyprlock.settings = lib.mkForce {
    general = {
      hide_cursor = true;
      ignore_empty_input = true;
    };

    auth = {
      pam.enabled = true;
      fingerprint = {
        enabled = true;
        ready_message = "Scan fingerprint or type password";
        present_message = "Scanning fingerprint";
      };
    };

    background = {
      color = "rgba(25, 20, 20, 1.0)";
      path = "screenshot";
      blur_passes = 2;
      brightness = 0.5;
    };

    label = {
      text = "$FPRINTPROMPT";
      color = "rgba(222, 222, 222, 1.0)";
      font_size = 24;
      font_family = "Noto Sans CJK JP";
      position = "0, 70";
      halign = "center";
      valign = "center";
    };

    input-field = {
      size = "300, 50";
      dots_size = 0.33;
      dots_spacing = 0.15;
      outer_color = "rgba(25, 20, 20, 0)";
      inner_color = "rgba(25, 20, 20, 0.6)";
      font_color = "rgba(222, 222, 222, 1.0)";
      placeholder_text = "Password";
      fail_text = "$FAIL ($ATTEMPTS)";
    };
  };

  services.swayidle = {
    enable = true;
    systemdTargets = [ "graphical-session.target" ];
    events = {
      # swayidle -w delays sleep until this returns.
      before-sleep = "${lockCmd} ${pkgs.coreutils}/bin/sleep 1";
      after-resume = "${niriMsg} power-on-monitors";
      lock = lockCmd;
    };
    timeouts = [
      {
        timeout = 120;
        command = "${brightnessctl} set 10% --save";
        resumeCommand = "${brightnessctl} --restore";
      }
      {
        timeout = 600;
        command = "${pkgs.systemd}/bin/loginctl lock-session";
      }
      {
        timeout = 1200;
        command = "${niriMsg} power-off-monitors";
        resumeCommand = "${niriMsg} power-on-monitors";
      }
      {
        timeout = 3600;
        command = "${pkgs.systemd}/bin/systemctl suspend";
      }
    ];
  };

  home.packages = with pkgs; [
    unstable.taskwarrior3
    unstable.agent-browser
    zen-browser.packages.x86_64-linux.zen-browser
    blender
    kicad
    gsettings-desktop-schemas
    arduino-ide
    libGL
    subsurface
    nodejs-slim_26
    unstable.prusa-slicer
    graphviz
    exiftool
    darktable
    unstable.codex
    unstable.pi-coding-agent
    unstable.claude-code
    unstable.rtk
    meld

    #system
    cifs-utils
    rclone
    restic

    #dev
    stdenv.cc
    doctl

    #saleae-logic
    #radicle-node
    jdk25

    #web
    unstable.ledger-live-desktop

    #scripts
    (writeShellScriptBin "brightness" (builtins.readFile ../../scripts/brightness))
    (writeShellScriptBin "wpa-add" (builtins.readFile ../../scripts/wpa-add-network))
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
  programs.ssh = {
    extraOptionOverrides = {
      CanonicalizeHostname = "yes";
    };
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
    initContent = ''
      export JAVA_HOME="${pkgs.jdk25}"
      export BW_SESSION="${config.settings.services.vaultwarden.sessionId}"
      #export JIRA_API_TOKEN=""
      #export AWS_PROFILE=""
      export LD_LIBRARY_PATH="${pkgs.libGL}/lib:/run/opengl-driver/lib"

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
  };
  programs.obs-studio.enable = true;
}
