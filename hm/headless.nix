{ config, pkgs, ... }:
{
  # services
  services.gpg-agent.pinentryPackage = pkgs.pinentry-curses;
}
