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

