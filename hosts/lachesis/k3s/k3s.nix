{ config, ... }:
let
  argocdChart = import ./charts/argocd.nix { };
in
{
  services.k3s = {
    enable = false;
    role = "server";
    token = config.settings.services.k3s.token;
    serverAddr = config.settings.services.k3s.serverAddr;
    extraFlags = [
      "--node-ip=${config.settings.services.k3s.nodeIP}"
      "--advertise-address=${config.settings.services.k3s.nodeIP}"
      "--node-external-ip=${config.settings.services.k3s.nodeIP}"
      "--tls-san=${config.settings.services.k3s.nodeIP}"
      "--disable=traefik"
      "--disable=nginx"
    ];
    autoDeployCharts = argocdChart;
  };

}
