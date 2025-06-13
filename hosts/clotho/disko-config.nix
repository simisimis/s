{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
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
          "CLOTHO" = {
            type = "zfs_fs";
            options.mountpoint = "none";
          };
          "CLOTHO/root" = {
            type = "zfs_fs";
            mountpoint = "/";
            options."com.sun:auto-snapshot" = "false";
          };
          "CLOTHO/home" = {
            type = "zfs_fs";
            mountpoint = "/home";
            options."com.sun:auto-snapshot" = "true";
          };
          "CLOTHO/nix" = {
            type = "zfs_fs";
            mountpoint = "/nix";
            options."com.sun:auto-snapshot" = "false";
          };
          "CLOTHO/media" = {
            type = "zfs_fs";
            mountpoint = "/srv/media";
            options."com.sun:auto-snapshot" = "false";
          };
          "CLOTHO/docker" = {
            type = "zfs_fs";
            mountpoint = "/srv/docker";
            options."com.sun:auto-snapshot" = "false";
          };
        };
      };
    };
  };
}
