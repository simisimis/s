# hm devops: shared kube / cloud / cli toolset for workstations and the devops profile
{ pkgs, unstable, ... }:
{
  imports = [
    ./modules/zellij
  ];

  programs.zellij.enable = true;
  programs.zoxide.enable = true;

  home.packages = with pkgs; [
    #kube
    kubectl
    kubectx
    k9s
    stern
    kubecolor
    krew
    kubernetes-helm
    unstable.helmfile
    helm-docs
    kustomize
    ksd
    #cloud
    unstable.terraform
    awscli2
    ec2-api-tools
    #dev
    gh
    just
    pre-commit
    actionlint
    grpcurl
    xh
    tmate
    #cli
    mtr
    dust
    procs
    eza
    tldr
    jq
  ];

  programs.zsh = {
    plugins = [
      {
        name = "fzf-tab";
        src = "${pkgs.zsh-fzf-tab}/share/fzf-tab";
      }
    ];
    initContent = ''
      source <(kubectl completion zsh)
      # make completion work with kubecolor
      compdef kubecolor=kubectl
    '';
    shellAliases = {
      kns = "kubens";
      kctx = "kubectx";
      k = "kubecolor";
      kubectl = "kubecolor";
    };
    cdpath = [ "~/dev" ];
  };
}
