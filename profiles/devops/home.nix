# devops profile: Home Manager on a non-NixOS work machine
{
  config,
  pkgs,
  unstable,
  ...
}:
{
  home.packages = with pkgs; [
    ansible
    jira-cli-go
    eksctl
    eks-node-viewer
    ssm-session-manager-plugin
    postgresql
    darktable
    ethtool
    #dev
    (google-cloud-sdk.withExtraComponents [ google-cloud-sdk.components.gke-gcloud-auth-plugin ])
  ];
}
