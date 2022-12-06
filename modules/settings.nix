# Settings file
{config, pkgs, lib, ...}:

with lib;

{
  options = {
    settings = {
      usr = {
        name = mkOption {
          default = "simas";
          type = with types; uniq str;
        };
        fullName = mkOption {
          default = "simas";
          type = with types; uniq str;
        };
        pwdHash = mkOption {
          default = "hash it with mkpasswd -m sha-512";
          type = with types; uniq str;
        };
        username = mkOption {
          default = "simisimis";
          type = with types; uniq str;
        };
        email = mkOption {
          default = "simonas@narbuto.lt";
          type = with types; uniq str;
        };
        ssh = {
          gitea.identityFile = mkOption {
            default = "~/.ssh/id_rsa_gitea_src_host";
            type = with types; uniq str;
          };
          backute.identityFile = mkOption {
            default = "~/.ssh/id_rsa_backute_src_host";
            type = with types; uniq str;
          };
          siMONSTER.identityFile = mkOption {
            default = "~/.ssh/id_rsa_src_host";
            type = with types; uniq str;
          };
          github.identityFile = mkOption {
            default = "~/.ssh/id_rsa_github_src_host";
            type = with types; uniq str;
          };
        };
      };
      hw = {
        hostName = mkOption {
          type = with types; uniq str;
          description = "don't be lazy. define it";
        };
        hostId = mkOption {
          type = with types; uniq str;
          description = "don't be lazy. define it";
        };
        videoDrv = mkOption {
          default = "mesa";
          type = with types; uniq str;
          description = "video driver";
        };
        wifi = mkOption {
          default = {};
          description = "set of ssids/pwds";
        };
      };
      services = {
        syncthing = {
          dataDir = mkOption {
            type = with types; uniq str;
            description = "directory to sync";
          };
          configDir = mkOption {
            type = with types; uniq str;
            description = "config dir ";
          };
          ids = mkOption {
            default = {};
            description = "set of ssids/pwds";
          };
        };
      };

      gitRepos = {
        binfiles = {
          ref = mkOption {
            default = "master";
            type = with types; uniq str;
          };
          rev = mkOption {
            default = "6e65c87f701529a68403647f47db937c7477c9f5";
            type = with types; uniq str;
          };
        };
        awesome = {
          ref = mkOption {
            default = "master";
            type = with types; uniq str;
          };
          rev = mkOption {
            default = "4abfaf5740c5ac8b5664f2d678cacd50957ad49f";
            type = with types; uniq str;
          };
        };
        zshd = {
          ref = mkOption {
            default = "master";
            type = with types; uniq str;
          };
          rev = mkOption {
            default = "3cd0a4e86cc0d4aea9ab13ad5f81ca4bdda90a35";
            type = with types; uniq str;
          };
        };
      };
      profile = mkOption {
        default = "simi";
        type = with types; uniq str;
        description = ''
          Profiles are a higher-level grouping than hosts. They are
          useful to combine multiple related things (e.g. ssh keys)
          that should be available on multiple hosts.
        '';
      };
    };
  };
}

