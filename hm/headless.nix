{ config, pkgs, ... }:
{
  # services
  services.gpg-agent.pinentryFlavor = "curses";
}
