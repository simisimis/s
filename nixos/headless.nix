{ pkgs, ... }:
{
  imports = [
    ./initrd-unlock.nix
    ../modules/k3s
  ];

  environment.systemPackages = with pkgs; [
    kubectl
    kubernetes-helm
    cilium-cli
    pinentry-curses
    esphome
    immich-cli
  ];
}
