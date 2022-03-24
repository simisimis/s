# backute specific home manager configuration
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
    extraConfig = {
      github.user = config.settings.usr.username;
    };
  };

  home.username = config.settings.usr.name;
  home.homeDirectory = "/home/${config.settings.usr.name}";

  systemd.user.services.notesync = {
    Unit = {
      Description = "sync notes to gdrive";
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.rclone}/bin/rclone sync /srv/docker/raneto/content  gdrive: -v";
      SuccessExitStatus = "0 1";
    };
  };

  systemd.user.timers.notesync = {
    Unit = {
      Description = "sync notes hourly";
    };
    Timer = {
      Unit = "notesync.service";
      OnCalendar = "*:0/15";
      Persistent = "true";
    };
    Install = {
      WantedBy = [ "timers.target" ];
    };
  };
}
