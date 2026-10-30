# siMONSTER specific home manager configuration
{ config, pkgs, unstable, ... }: {
  services.kanshi.enable = true;
  services.kanshi.settings = [{
    profile.name = "office";
    profile.outputs = [{
      criteria = "Dell Inc. DELL U4025QW FNHNF34";
      position = "0,0";
      scale = 1.6;
      mode = "5120x2160@60.000Hz";
      status = "enable";
    }];
  }];
  home.packages = with pkgs; [
    # system
    rclone
    #saleae-logic

    unstable.prusa-slicer
    unstable.llmfit
    #minecraft
    #airshipper
  ];
}
