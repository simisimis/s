# devops profile: Home Manager on a non-NixOS work machine
{
  config,
  pkgs,
  unstable,
  ...
}:
{
  imports = [ ../../hm/modules/helix ];
  programs.helix.enable = true;

  programs.diff-so-fancy = {
    enable = true;
    enableGitIntegration = true;
  };
  programs.git = {
    signing.key = "45F417054C1910F8";
    settings = {
      user.name = config.settings.usr.fullName;
      user.email = config.settings.usr.email;
      github.user = config.settings.usr.username;
      fetch.prune = true;
      fetch.pruneTags = true;
    };
  };

  home.packages = with pkgs; [
    mtr
    ansible
    just
    pre-commit
    ec2-api-tools
    jira-cli-go
    grpcurl
    actionlint
    tmate
    gh
    #unstable.awscli2
    awscli2
    eksctl
    eks-node-viewer
    kubernetes-helm
    kubecolor
    krew
    unstable.helmfile
    ksd
    ssm-session-manager-plugin
    postgresql
    dust
    procs
    eza
    tldr
    darktable
    ethtool
    #dev
    (google-cloud-sdk.withExtraComponents [ google-cloud-sdk.components.gke-gcloud-auth-plugin ])
    kubectx
    kubectl
    k9s
    stern
    unstable.terraform
  ];
  programs.zsh = {
    cdpath = [ "~/dev" ];
    initContent = ''
      source <(kubectl completion zsh)
    '';
    shellAliases = {
      kns = "kubens";
      kctx = "kubectx";
      k = "kubecolor";
    };
  };
  programs.zoxide.enable = true;
}
