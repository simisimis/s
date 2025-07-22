{ config, lib, ... }: {
  services.k3s = with config.settings.services.k3s; {
    enable = true;
    role = "server";
    token = token;
    serverAddr = lib.mkIf (serverAddr != "") serverAddr;
    extraFlags = [
      "--node-ip=${nodeIP}"
      #"--advertise-address=${nodeIP}"
      "--node-external-ip=${nodeIP}"
      "--tls-san=${nodeIP}"
      "--write-kubeconfig-mode=0644"
      #"--disable=local-storage"
      "--disable=servicelb" # Disable built-in Klipper LoadBalancer
      "--disable=traefik" # Disable built-in ingress controller
      "--disable=metrics-server" # If you use a different metrics solution
      "--flannel-backend=none" # Disable k3s default CNI (Flannel)
      "--disable-network-policy" # Let Cilium handle network policies
      "--disable-cloud-controller"
      "--disable=kube-proxy" # Let Cilium handle kube-proxy duties with eBPF
      #"--disable=coredns" # deploy ourselves
      "--disable-helm-controller" # manage helm charts differently
    ];
    clusterInit = (config.settings.hw.hostName == "clotho");
  };
}
