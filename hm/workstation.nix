# hm workstation
{ config, nixpkgs-unstable, pkgs, autoPatchelfHook, ... }:
let
  unstable = import nixpkgs-unstable {
    system = "x86_64-linux";
    config = {
      allowUnfree = true;
      android_sdk.accept_license = true;
    };
  };
  plasticityVersion = "25.2.1";
  plasticityNew = pkgs.plasticity.overrideAttrs (oldAttrs: {
    version = "${plasticityVersion}";
    src = pkgs.fetchurl {
      url =
        "https://github.com/nkallen/plasticity/releases/download/v${plasticityVersion}/Plasticity-${plasticityVersion}-1.x86_64.rpm";
      hash = "sha256-M0TjHTTVs37QwG8XCy4+R0mD7Ttipwebd7+IHWhA7UI=";
    };
  });
in {
  imports = [ ./modules/zellij ./modules/helix ];

  nixpkgs.config.allowUnfree = true;
  home.packages = with pkgs; [
    # start wayland
    swaylock
    swayidle
    waybar
    wdisplays
    mako # notification daemon
    wtype
    waybar
    wl-clipboard
    wofi
    wofi-emoji

    fantasque-sans-mono
    font-awesome_5
    roboto-mono
    nerd-fonts.mononoki
    material-icons
    adwaita-icon-theme
    libappindicator
    # end wayland
    #utils
    ethtool
    brightnessctl
    pamixer
    slurp
    grim
    (writeShellScriptBin "trimgrim" (builtins.readFile ../scripts/trimgrim))
    (writeShellScriptBin "cal-tooltip"
      (builtins.readFile ../scripts/cal-tooltip))
    (writeShellScriptBin "browser" (builtins.readFile ../scripts/browser))
    (writeShellScriptBin "plasticity" ''
      exec ${plasticityNew}/bin/Plasticity --ozone-platform=wayland --use-gl=egl
    '')
    pavucontrol
    speedcrunch
    (flameshot.override {
      # Enable USE_WAYLAND_GRIM compile flag
      enableWlrSupport = true;
    })
    nemo
    nushell
    pinentry-gtk2

    #web
    (pkgs.wrapFirefox
      (pkgs.firefox-unwrapped.override { pipewireSupport = true; }) { })
    (brave.override { commandLineArgs = [ "--ozone-platform-hint=auto" ]; })

    #media
    gthumb
    digikam
    feh
    imv
    gimp
    obs-studio
    ffmpeg-full
    mpv-unwrapped
    spotify
    calibre

    #elf shennanigens
    patchelf
    nix-index
    binutils
    gnumake
    gcc
    stdenv.cc.cc.lib

    #dev
    unstable.obsidian
    go
    golint
    delve
    exercism
    unstable.android-studio
    rust-analyzer
    rustc
    cargo
    rustfmt
    cargo-edit
    clippy
    cargo-watch
    bacon
    trunk
    wasm-pack
    wasm-bindgen-cli
    # rustup
    #rnix-lsp
    (python312.withPackages (ps:
      with ps; [
        pyserial
        west
        intelhex
        termcolor
        crcmod
        requests
        ruamel_yaml
        pip
        yamllint
        flake8
        setuptools
        shapely
      ]))
    gitAndTools.gitflow

    #unstable.prusa-slicer
  ];

  # services
  services.gpg-agent.pinentry.package = pkgs.pinentry-gtk2;

  programs.vscode = with pkgs; {
    enable = false;
    profiles.default = {
      extensions = with vscode-extensions; [
        golang.go
        hashicorp.terraform
        vscodevim.vim
        redhat.vscode-yaml
        redhat.java
        ms-vscode-remote.remote-ssh

        # third party extensions
        #arrterian.nix-env-selector
        brettm12345.nixfmt-vscode
        bbenoist.nix
      ];
      userSettings = {
        "telemetry.enableCrashReporter" = false;
        "telemetry.enableTelemetry" = false;
        # ViM settings
        "vim.normalModeKeyBindingsNonRecursive" = [
          {
            "before" = [ "u" ];
            "after" = [ ];
            "commands" = [{
              "command" = "undo";
              "args" = [ ];
            }];
          }
          {
            "before" = [ "<C-r>" ];
            "after" = [ ];
            "commands" = [{
              "command" = "redo";
              "args" = [ ];
            }];
          }
        ];
        "go.toolsManagement.autoUpdate" = false;
        "window.zoomLevel" = 0;
        "editor.formatOnSave" = true;

        "workbench.colorTheme" = "Solarized Light";
        "workbench.iconTheme" = null;
        "workbench.colorCustomizations" = {
          "editor.selectionBackground" = "#edcda8";
          "editor.selectionHighlightBackground" = "#edcda8";
        };
        "explorer.confirmDragAndDrop" = false;
        "search.useIgnoreFiles" = false;
        "explorer.confirmDelete" = false;
        "editor.fontFamily" =
          "'Droid Sans Mono', monospace, 'Droid Sans Fallback'";
        "java.jdt.ls.java.home" = "${pkgs.jdk11}/lib/openjdk";
        "java.configuration.runtimes" = [{
          "name" = "JavaSE-11";
          "path" = "${pkgs.jdk11}/lib/openjdk";
          "default" = true;
        }];
        "java.project.referencedLibraries" =
          [ "/home/snarbutas/development/java/algorithmsp1/lib/algs4.jar" ];
      };
    };
  };
  programs.zellij.enable = true;
  programs.helix.enable = true;
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

  home.file.".local/share/applications/browser.desktop".text = ''
    #!/usr/bin/env xdg-open
    [Desktop Entry]
    Version=1.0
    Terminal=false
    Type=Application
    Name=Browser select
    Exec=browser
    MimeType=x-scheme-handler/unknown;x-scheme-handler/about;x-scheme-handler/https;x-scheme-handler/http;text/html;
  '';

  xdg = {
    configFile."mimeapps.list".force = true;
    mimeApps = {
      enable = true;
      associations.added = {
        "x-scheme-handler/magnet" = "userapp-transmission-gtk-XEE0Y0.desktop";
      };
      defaultApplications = {
        "image/jpeg" = "imv-folder.desktop";
        "image/png" = "imv-folder.desktop";
        "image/gif" = "imv-folder.desktop";
        "text/html" = "browser.desktop";
        "x-scheme-handler/http" = "browser.desktop";
        "x-scheme-handler/https" = "browser.desktop";
        "x-scheme-handler/about" = "browser.desktop";
        "x-scheme-handler/unknown" = "browser.desktop";
        "x-scheme-handler/magnet" = "userapp-transmission-gtk-XEE0Y0.desktop";
        "x-scheme-handler/msteams" = "teams.desktop";
        "application/pdf" = "zathura.desktop";
        "video/mp4" = "umpv.desktop;mpv.desktop";
        "video/quicktime" = "umpv.desktop;mpv.desktop";
      };
    };
  };
  programs.ssh = {
    enable = true;
    matchBlocks = {
      "192.168.178.100" = {
        user = "simas";
        identityFile = config.settings.usr.ssh.backute.identityFile;
      };
      "github.com" = {
        user = "git";
        identityFile = config.settings.usr.ssh.github.identityFile;
        extraOptions = {
          AddKeysToAgent = "yes";
          PubKeyAuthentication = "yes";
        };
      };
    };
  };
  programs.waybar = {
    enable = true;
    settings = [{
      "height" = 30;
      "modules-left" = [ "sway/workspaces" "hyprland/workspaces" ];
      "modules-right" = [
        "network"
        "network#wl"
        "backlight"
        "cpu"
        "memory"
        "pulseaudio"
        "sway/language"
        "hyprland/language"
        "custom/date"
        "tray"
        "battery"
        "custom/power"
      ];
      "hyprland/workspaces" = {
        format = " {icon} ";
        format-icons = {
          "1" = "🖋";
          "2" = "";
          "3" = "";
          "4" = "";
          "5" = "";
          "6" = "";
          "active" = "";
          "default" = "";
        };
        persistent-workspaces = {
          "1" = [ ];
          "2" = [ ];
          "3" = [ ];
          "4" = [ ];
          "5" = [ ];
          "6" = [ ];
        };
      };
      "sway/workspaces" = {
        all-outputs = true;
        format = " {icon} ";
        persistent_workspaces = {
          "1" = [ ];
          "2" = [ ];
          "3" = [ ];
          "4" = [ ];
          "5" = [ ];
        };
        format-icons = {
          "1" = "";
          "2" = "";
          "3" = "";
          "4" = "";
          "5" = "";
          "6" = "🖋";
          "urgent" = "";
          "focused" = "";
          "default" = "";
        };
      };
      "backlight" = {
        format = "{percent}% {icon}";
        format-icons = [ "" "" ];
        on-scroll-up = "brightnessctl s +1%";
        on-scroll-down = "brightnessctl s 1%-";
      };
      "cpu" = {
        format = "{usage}% 🧠";
        tooltip = false;
      };
      "memory" = { format = "{}% "; };
      "battery" = {
        states = {
          warning = 30;
          critical = 15;
        };
        format = "{icon} ";
        format-charging = "{capacity}% ";
        format-plugged = "{capacity}% ";
        format-alt = "{capacity}% {icon} ";
        format-icons = [ "" "" "" "" "" ];
      };
      "network" = {
        interface = "eth*";
        format-ethernet = "🖧";
        format-linked = "{ifname} (No IP) 🖧";
        format-disconnected = "Disconnected 🖧";
        tooltip = false;
        format-alt = "ip:{ipaddr}🖧";
      };
      "network#wl" = {
        interface = "wlp*";
        format-wifi = "({signalStrength}%) ";
        format-linked = "{ifname} (No IP) ";
        format-disconnected = "Disconnected ⚠";
        tooltip = false;
        format-alt = "{essid} ip:{ipaddr}";
      };
      "pulseaudio" = {
        format = "{volume}% {icon} {format_source}";
        format-bluetooth = "{volume}% {icon} {format_source}";
        format-bluetooth-muted = " {icon} {format_source}";
        format-muted = " {format_source}";
        format-source = "{volume}% ";
        format-source-muted = "";
        format-icons = {
          headphone = "";
          hands-free = "";
          headset = "";
          phone = "";
          portable = "";
          car = "";
          default = [ "" "" "" ];
        };
        on-click = "pavucontrol";
      };
      "tray" = {
        icon-size = 21;
        spacing = 10;
      };
      "custom/date" = {
        format = "{}";
        return-type = "json";
        interval = 60;
        exec = "cal-tooltip";
      };
      "custom/power" = {
        format = "🔌";
        on-click =
          "swaynag -m'Are you sure?' -b 'Suspend' 'systemctl suspend; pkill swaynag'";
        tooltip = false;
      };
      "custom/vpn" = {
        interval = 15;
        return-type = "json";
        format = "{icon}";
        format-icons = [ "" "" ];
        exec = "exec vpn-handler status json";
        on-click = "exec vpn-handler start from-other";
        on-click-middle = "exec vpn-handler stop";
        on-click-right = "exec vpn-handler start tunnel-all";
      };
    }];
    style = ''
      * {
          border: none;
          border-radius: 0;
          /* `otf-font-awesome` is required to be installed for icons */
          font-family: "JetBrainsMono", "Font Awesome 5 Brands Regular", "Font Awesome 5 Free", "Meslo LG S DZ";
          font-size: 14px;
          min-height: 0;
      }

      window#waybar {
          background: transparent;

          /*border-bottom: 3px solid rgba(100, 114, 125, 0.5);*/
          color: #ffffff;
          transition-property: background-color;
          transition-duration: .2s;
      }
      #workspaces button {
          padding: 5px 10px;
          color: #c0caf5;
      }

      #workspaces button.focused {
          color: #24283b;
          background-color: #7aa2f7;
          border-radius: 5px;
      }

      #workspaces button:hover {
        background-color: #7dcfff;
        color: #24283b;
        border-radius: 5px;
      }

      tooltip {
          border-radius: 4px;
          background-color: rgba(33, 14, 32, 0.8);
      }
      tooltip label {
          font-family: 'JetBrainsMono', 'Roboto Mono Thin';
          font-size: 16px;
          color: white;
      }

      window#waybar.chromium {
          background-color: #000000;
          border: none;
      }
      #workspaces button.urgent {
          background-color: #eb4d4b;
      }

      #workspaces {
        background-color: #44485b;
        margin: 2px 0px 0px 0px;
        border-radius: 5px;
      }

      /* If workspaces is the leftmost module, omit left margin */
      .modules-left > widget:first-child > #workspaces {
          margin-left: 0;
      }

      /* If workspaces is the rightmost module, omit right margin */
      .modules-right > widget:last-child > #workspaces {
          margin-right: 0;
      }

      #backlight, #cpu, #memory, #language, #custom-date, #custom-vpn, #battery, #pulseaudio, #network, #tray {
        background-color: #44485b;
        padding: 5px 10px;
        margin: 2px 0px 0px 0px;
        border-radius: 0px 0px 0px 0px;
      }

      #backlight {
          color: #bd64bd;
      }
      #network {
        color: #bb79d6;
        border-radius: 5px 0px 0px 5px;
      }
      #network.wl {
        border-radius: 0px 0px 0px 0px;
      }

      #network.disconnected {
          color: #f53c3c;
      }

      #cpu {
        color: #f7768e;
      }

      #memory {
          color: #ee7575;
      }

      #pulseaudio {
          color: #e0af68;
      }

      #pulseaudio.muted {
          background-color: #90b1b1;
          color: #2a5c45;
      }

      #language {
          color: #68de4d;
      }

      #custom-date {
          color: #4ddede;
      }

      #custom-vpn {
          color: #e75d4a;
      }

      #custom-vpn.connected {
          color: #68de4d;
      }

      #custom-power {
        font-size: 12px;
        color: #24283b;
        background-color: #db4b4b;
        border-radius: 5px;
        margin-right: 3px;
        margin-top: 3px;
        margin-bottom: 3px;
        margin-left: 3px;
        padding: 5px 10px;
      }

      #battery {
        color: #9ece6a;
        border-radius: 0px 5px 5px 0px;
      }

      #battery.charging, #battery.plugged {
          color: #44485b;
          animation-name: blink;
          animation-duration: 1s;
          animation-timing-function: linear;
          animation-iteration-count: infinite;
          animation-direction: alternate;
      }

      @keyframes blink {
          to {
              color: #9ece6a;
          }
      }

      #battery.critical:not(.charging) {
          color: #f7768e;
          animation-name: blink;
          animation-duration: 0.5s;
          animation-timing-function: linear;
          animation-iteration-count: infinite;
          animation-direction: alternate;
      }

      label:focus {
          background-color: #000000;
      }
    '';
    systemd.enable = false;
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
  home.file.".config/wofi/config".text = ''
    width=400
    height=200
  '';
  home.file.".config/wofi/style.css".text = ''
    #window {
      padding: 2px;
      background-color: transparent;
      border-radius: 2px;
      font-family: "Meslo LG S DZ", "JetBrainsMono";
      font-size: 15px;
    }

    #input {
      border: transparent;
      background-color: rgba(68, 72, 91, 0.85);
      caret-color: #c0caf5;
      color: #c0caf5;
      padding: 3px 5px 3px 5px;
      border-radius: 5px;
    }

    #entry:selected {
      background-color: #7aa2f7;
      border-radius: 5px;
    }

    #text:selected {
      color: #24283b;
    }

    #inner-box {
      color: #d8dee9;
      border-radius: 5px;
      padding: 2px;
      background-color: rgba(68, 72, 91, 0.85);
    }

    #outer-box {
      margin: 15px;
      background-color: transparent;
    }

    #scroll {
      margin-top: 10px;
      background-color: transparent;
      border: none;
    }

    #text {
      padding: 3px;
      color: #c0caf5;
      background-color: transparent;
    }

    #img {
      background-color: transparent;
      padding: 5px;
    }
  '';
}
