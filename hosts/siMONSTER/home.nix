# siMONSTER specific home manager configuration
{ nixosConfig, config, pkgs, lib, ... }:
let
  unstable = import <nixos-unstable> { config.allowUnfree = true; };
in
{
  imports = [
    ../../hm/base.nix
    ../../hm/workstation.nix
  ];
  programs.git = {
    userName = nixosConfig.settings.usr.name;
    userEmail = nixosConfig.settings.usr.email;
    extraConfig = {
      github.user = nixosConfig.settings.usr.username;
    };
  };
  home.username = nixosConfig.settings.usr.name;
  home.homeDirectory = "/home/${nixosConfig.settings.usr.name}";

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
      output = { "*" = { bg = "~/Pictures/owl1.jpg fit"; } ; };
      keybindings = let
        modifier = config.wayland.windowManager.sway.config.modifier;
        in lib.mkOptionDefault {
          #"${modifier}+Return" = "exec ${pkgs.termite}/bin/termite";
          "${modifier}+g" = "move workspace to output left";
          "${modifier}+b" = "move workspace to output up";
          "${modifier}+Shift+t" = "exec trimgrim";
          "${modifier}+Shift+p" = "exec wofipass";
          "${modifier}+Shift+q" = "kill";
          "${modifier}+Shift+l" = "exec swaylock -f -i ~/Pictures/texture1_1.jpg -t";
          "${modifier}+d" = "exec ${pkgs.wofi}/bin/wofi --show run | ${pkgs.findutils}/bin/xargs swaymsg exec --";
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
          criteria = "DP-2";
          position = "1920,0";
          scale = 1.8;
        }
        {
          criteria = "HDMI-A-2";
          position = "4053,70";
          scale = 1.0;
        }
      ];
    };
  };
  home.packages = with pkgs; [
    # start wayland
    swaylock
    swayidle
    wl-clipboard
    ethtool
    mako # notification daemonhome.
    wofi
    waybar
    slurp
    grim
    brightnessctl
    pamixer
    wdisplays

    font-awesome
    roboto-mono
    (nerdfonts.override { fonts = [ "Mononoki" ]; })
    material-icons
    gnome.adwaita-icon-theme
    # end wayland
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
      background_opacity = 0.9;
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
}
