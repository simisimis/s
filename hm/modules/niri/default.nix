{ pkgs, ... }: {
  # Edit config.kdl locally, then apply with home-manager switch.
  # Previous custom settings are preserved in backups/custom-20260930-222246.nix.
  xdg.configFile."niri/config.kdl".source = ./config.kdl;

  # Applications used by Niri; trimgrim comes from workstation.nix.
  home.packages = with pkgs; [ wezterm fuzzel playerctl swaybg ];
}
