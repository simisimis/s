{ pkgs, ... }: {
  # Edit config.kdl locally, then apply with home-manager switch.
  xdg.configFile."niri/config.kdl".source = ./config.kdl;

  # Applications used by Niri; trimgrim comes from workstation.nix.
  home.packages = with pkgs; [ wezterm fuzzel playerctl swaybg ];
}
