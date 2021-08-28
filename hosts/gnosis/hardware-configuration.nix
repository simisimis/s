# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "zroot/ROOT/default";
      fsType = "zfs";
    };

  fileSystems."/nix" =
    { device = "zroot/NIX/store";
      fsType = "zfs";
    };

  fileSystems."/home" =
    { device = "zroot/USER/home";
      fsType = "zfs";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/1E40-7164";
      fsType = "vfat";
    };

  fileSystems."/tmp" =
    { device = "zroot/ROOT/tmp";
      fsType = "zfs";
    };

  swapDevices = [ ];

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  # high-resolution display
  hardware.video.hidpi.enable = lib.mkDefault true;
}
