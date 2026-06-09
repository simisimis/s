# siMONSTER specific home manager configuration
{ config, pkgs, unstable, ... }: {
  settings = import ./vars.nix;
  # import overlays
  nixpkgs.overlays = [ (import ../../overlays) ];
  programs.home-manager.enable = true;
  programs.diff-so-fancy.enable = true;
  programs.git = {
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
  services.kanshi.settings = [{
    profile.name = "office";
    profile.outputs = [{
      criteria = "Dell Inc. DELL U4025QW FNHNF34";
      position = "0,0";
      scale = 1.6;
      mode = "5120x2160@60.000Hz";
      status = "enable";
    }];
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
    extraConfig = ''
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
      format = ''
        <b>%s</b>
        %b'';
    };
  };
}
