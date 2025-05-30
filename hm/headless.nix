{ config, pkgs, ... }:
{
  # services
  services.gpg-agent.pinentry.package = pkgs.pinentry-curses;
}
