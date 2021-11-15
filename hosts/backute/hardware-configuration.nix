# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" "sdhci_pci" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "zroot/ROOT/default";
      fsType = "zfs";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/C8D2-7B26";
      fsType = "vfat";
    };

  fileSystems."/tmp" =
    { device = "zroot/ROOT/tmp";
      fsType = "zfs";
    };

  fileSystems."/home" =
    { device = "zroot/DATA/home";
      fsType = "zfs";
    };

  fileSystems."/srv/media" =
    { device = "zroot/DATA/media";
      fsType = "zfs";
    };

  fileSystems."/srv/docker" =
    { device = "zroot/DATA/docker";
      fsType = "zfs";
    };

  fileSystems."/srv/dbs" =
    { device = "zroot/DATA/dbs";
      fsType = "zfs";
    };

  fileSystems."/nix" =
    { device = "zroot/NIX/store";
      fsType = "zfs";
    };

  fileSystems."/var/lib/docker" =
    { device = "zroot/DOCKER/dockerd";
      fsType = "zfs";
    };

  swapDevices = [ ];

  nix.maxJobs = lib.mkDefault 4;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  # High-DPI console
  console.font = lib.mkDefault "${pkgs.terminus_font}/share/consolefonts/ter-u28n.psf.gz";
}
