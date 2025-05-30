# siMONSTER specific home manager configuration
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
    diff-so-fancy.enable = true;
    extraConfig = {
      github.user = config.settings.usr.username;
      fetch.prune = true;
      fetch.pruneTags = true;
    };
  };
  home.username = config.settings.usr.name;
  home.homeDirectory = "/home/${config.settings.usr.name}";

  wayland.windowManager.hyprland = {
    enable = true;

    settings = {
      exec-once = [ "waybar" "systemctl --user restart kanshi" ];
      env = [
        "ELECTRON_OZONE_PLATFORM_HINT,auto"
      ];


      general = {
        gaps_in = 1;
        gaps_out = 2;
      };

      "$launcher" = "wofi --show run";
      "$browser" = "firefox";
      "$terminal" = "wezterm";

      input = {
        kb_layout = "us,lt,gr";
        kb_options = "ctrl:nocaps,grp:ctrl_space_toggle";
      };

      bind = [
        "SUPER, D, exec, $launcher"

        "SUPER, Return, exec, $terminal"
        "SUPER SHIFT, Q, killactive"
        "SUPER, F, fullscreen"

        "SUPER, up, movefocus, u"
        "SUPER, down, movefocus, d"
        "SUPER, left, movefocus, l"
        "SUPER, right, movefocus, r"

        "SUPER, 1, workspace, 1"
        "SUPER, 2, workspace, 2"
        "SUPER, 3, workspace, 3"
        "SUPER, 4, workspace, 4"
        "SUPER, 5, workspace, 5"
        "SUPER, 6, workspace, 6"
        "SUPER, 7, workspace, 7"
        "SUPER, 8, workspace, 8"

        "CTRL SUPER, left, workspace, r-1"
        "CTRL SUPER, right, workspace, r+1"

        "SUPER SHIFT, 1, movetoworkspace, 1"
        "SUPER SHIFT, 2, movetoworkspace, 2"
        "SUPER SHIFT, 3, movetoworkspace, 3"
        "SUPER SHIFT, 4, movetoworkspace, 4"
        "SUPER SHIFT, 5, movetoworkspace, 5"
        "SUPER SHIFT, 6, movetoworkspace, 6"
        "SUPER SHIFT, 7, movetoworkspace, 7"
        "SUPER SHIFT, 8, movetoworkspace, 8"

        "SUPER SHIFT, T, exec, trimgrim"
        "SUPER SHIFT, B, exec, wofi-emoji"
        "SUPER SHIFT, C, exit"
      ];
      bindm = [
        "SUPER, mouse:272, movewindow"
        "SUPER, mouse:273, resizewindow"
      ];


      # https://wiki.hyprland.org/Configuring/Variables/#misc
      misc = {
        force_default_wallpaper = 2;
      };
      bezier = "ease_out_quint, 0.22, 1, 0.36, 1";
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
  services.kanshi.settings = [{
    profile.name = "office";
    profile.outputs = [
      {
        criteria = "Dell Inc. DELL U4025QW FNHNF34";
        position = "0,0";
        scale = 1.6;
        mode = "5120x2160@60.000Hz";
        status = "enable";
      }
    ];
  }];
  home.packages = with pkgs; [
    # system
    rclone
    #saleae-logic

    unstable.prusa-slicer
    #minecraft
    #airshipper
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
  services.mako = {
    enable = true;
    settings = {
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
      format = "<b>%s</b>\n%b";
    };
  };
}
