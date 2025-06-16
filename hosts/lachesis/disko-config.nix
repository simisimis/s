{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/sda";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zroot";
              };
            };
          };
        };
      };
    };
    zpool = {
      zroot = {
        type = "zpool";
        rootFsOptions = {
          acltype = "posixacl";
          atime = "off";
          compression = "zstd";
          mountpoint = "none";
          encryption = "aes-256-gcm";
          keyformat = "passphrase";
          keylocation = "prompt";
          xattr = "sa";
        };
        options.ashift = "12";
        options.autotrim = "on";

        datasets = {
          "LACHESIS" = {
            type = "zfs_fs";
            options.mountpoint = "none";
          };
          "LACHESIS/root" = {
            type = "zfs_fs";
            mountpoint = "/";
            options."com.sun:auto-snapshot" = "false";
          };
          "LACHESIS/home" = {
            type = "zfs_fs";
            mountpoint = "/home";
            options."com.sun:auto-snapshot" = "true";
          };
          "LACHESIS/nix" = {
            type = "zfs_fs";
            mountpoint = "/nix";
            options."com.sun:auto-snapshot" = "false";
          };
          "LACHESIS/data" = {
            type = "zfs_fs";
            mountpoint = "/srv/data";
            options."com.sun:auto-snapshot" = "false";
          };
          "LACHESIS/docker" = {
            type = "zfs_fs";
            mountpoint = "/srv/docker";
            options."com.sun:auto-snapshot" = "false";
          };
        };
      };
    };
  };
}
