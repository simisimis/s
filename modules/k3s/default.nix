{ config, pkgs, lib, ... }: {
  services.etcd = with config.settings.services.etcd; {
    enable = true;
    listenClientUrls =
      [ "http://${hosts.${config.settings.hw.hostName}}:2379" ];
    listenPeerUrls = [ "http://${hosts.${config.settings.hw.hostName}}:2380" ];
    initialAdvertisePeerUrls =
      [ "http://${hosts.${config.settings.hw.hostName}}:2380" ];
    initialCluster =
      lib.mapAttrsToList (name: value: "${name}=http://${value}:2380") hosts;
    initialClusterState = "existing";
    initialClusterToken = "${config.settings.services.k3s.token}";
  };
  services.k3s = with config.settings.services.k3s; {
    enable = true;
    role = "server";
    token = token;
    serverAddr = lib.mkIf (serverAddr != "") serverAddr;
    extraFlags = [
      "--node-ip=${nodeIP}"
      "--node-external-ip=${nodeIP}"
      "--tls-san=${nodeIP}"
      "--write-kubeconfig-mode=0644"
      "--disable=local-storage"
      "--disable=servicelb" # Disable built-in Klipper LoadBalancer
      "--disable=traefik" # Disable built-in ingress controller
      "--disable=metrics-server" # If you use a different metrics solution
      "--flannel-backend=none" # Disable k3s default CNI (Flannel)
      "--disable-network-policy" # Let Cilium handle network policies
      "--disable-cloud-controller"
      "--disable=kube-proxy" # Let Cilium handle kube-proxy duties with eBPF
      #"--disable=coredns"
      "--disable-helm-controller" # manage helm charts differently
      ("--datastore-endpoint=" + (lib.concatStringsSep ","
        (lib.mapAttrsToList (_: v: "http://${v}:2379")
          config.settings.services.etcd.hosts)))

    ];
    clusterInit = (config.settings.hw.hostName == "clotho");
  };
  systemd.tmpfiles.rules = [
    "L+ /sbin/zfs - - - - ${pkgs.zfs}/bin/zfs"
    "L+ /sbin/zpool - - - - ${pkgs.zfs}/bin/zpool"
  ];
}
