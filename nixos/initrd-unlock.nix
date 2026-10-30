# Remote ZFS unlock over SSH from the initrd. Hosts only add the NIC driver
# they need to boot.initrd.kernelModules.
{ config, pkgs, ... }:
let
  keys = import ../modules/keys.nix;
  initrdUnlockShell = pkgs.writeShellScript "initrd-zfs-unlock-shell" ''
    echo "Waiting for initrd password prompts"
    exec ${config.boot.initrd.systemd.package}/bin/systemd-tty-ask-password-agent
  '';
in
{
  boot.initrd = {
    systemd = {
      extraBin.initrd-unlock = "${initrdUnlockShell}";
      users.root.shell = initrdUnlockShell;
    };
    network = {
      enable = true;
      ssh = {
        enable = true;
        port = 2222;
        hostKeys = [ "/etc/secrets/initrd/initrd-openssh-key" ];
        authorizedKeys = [ keys.initrd ];
      };
    };
  };
}
