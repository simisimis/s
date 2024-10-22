# backute specific home manager configuration
{ config, pkgs, nixpkgs-unstable, ... }:
let
  unstable = import nixpkgs-unstable {
    system = "x86_64-linux";
    config = { allowUnfree = true; };
  };
in
{
  imports = [
    ../../hm/modules/helix
  ];
  programs.helix.enable = true;

  settings = import ./vars.nix;
  # import overlays
  nixpkgs.overlays = [ (import ../../overlays) ];
  programs.home-manager.enable = true;
  programs.git = {
    userName = config.settings.usr.fullName;
    userEmail = config.settings.usr.email;
    diff-so-fancy.enable = true;
    signing.key = "45F417054C1910F8";
    extraConfig = {
      github.user = config.settings.usr.username;
      fetch.prune = true;
      fetch.pruneTags = true;
    };
  };

  home.username = config.settings.usr.name;
  home.homeDirectory = "/home/${config.settings.usr.name}";

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
    du-dust
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
  systemd.user.tmpfiles.rules = [ "d %h/dev/MinaFoundation 755 - - - -" ];
  programs.zsh = {
    cdpath = [
      "~/dev/MinaFoundation"
    ];
    initExtra = ''
      source ~/.nix-profile/etc/profile.d/nix.sh
      source <(kubectl completion zsh)
      export AWS_PROFILE="mina"
      aws-portforward () {
        CLUSTER=$1
        HOST=$2
        LOCAL=$3
        PORT=$4

        NODEGROUP=$(aws eks list-nodegroups --cluster-name $CLUSTER --query 'nodegroups' --output text)
        SCALINGGROUP=$(aws eks describe-nodegroup --cluster-name $CLUSTER --nodegroup-name $NODEGROUP --query 'nodegroup.resources.autoScalingGroups[*].name' --output text)
        INSTANCEID=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names $SCALINGGROUP --query 'AutoScalingGroups[*].Instances[0].InstanceId' --output text)
        PARAMETERS=$(jq -n --arg port $PORT --arg host $HOST --arg local $LOCAL '{"portNumber":[$port],"localPortNumber":[$local],"host":[$host]}')

        aws ssm start-session --target $INSTANCEID --document-name AWS-StartPortForwardingSessionToRemoteHost --parameters "$PARAMETERS" 
      }
    '';
    shellAliases = {
      kns = "kubens";
      kctx = "kubectx";
      k = "kubecolor";
    };
  };
  programs.zoxide.enable = true;
}
