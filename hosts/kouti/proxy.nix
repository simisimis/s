###########################
### Proxy components:
### - Cloudflare tunnel
### - Authelia auth
### - Traefik reverse proxy
### - Services
###########################
{ config, lib, nixpkgs-unstable, ... }:
let
  unstable = import nixpkgs-unstable {
    system = "x86_64-linux";
    config = { allowUnfree = true; };
  };
  user_database = builtins.toFile "user_database.yml" (
    lib.generators.toYAML { } {
      users = {
        "${config.settings.usr.name}" = {
          disabled = false;
          displayname = config.settings.usr.fullName;
          password = config.settings.services.authelia.userPassword;
          email = config.settings.usr.email;
          groups = [ "admins" "dev" ];
        };
      };
    });
  vaultwardenEnv = builtins.toFile "vaultwarden.env" ''
    ADMIN_TOKEN="${config.settings.services.vaultwarden.adminToken}"
  '';

in
{
  ###########################
  ### --- Cloudflared --- ###
  ###########################
  services.cloudflared = {
    enable = true;
    user = "${config.settings.usr.name}";
    tunnels."${config.settings.hw.hostName}" = {
      credentialsFile =
        builtins.toFile "credentialsFile.json" (builtins.toJSON config.settings.services.cloudflared.tunnelCredentials);
      ingress = {
        "*.narbuto.lt" = { service = "https://localhost:443"; };
      };
      originRequest.noTLSVerify = true;
      default = "http_status:404";
    };
  };

  ########################
  ### --- Authelia --- ###
  ########################
  services.authelia.instances.default = {
    enable = true;
    user = "${config.settings.usr.name}";

    secrets = {
      jwtSecretFile = (builtins.toFile "jwtSecret" config.settings.services.authelia.jwtSecret);
      storageEncryptionKeyFile = (builtins.toFile "storageEncryptionKey" config.settings.services.authelia.storageEncryptionKey);
      sessionSecretFile = (builtins.toFile "sessionSecret" config.settings.services.authelia.sessionSecret);
      #oidcHmacSecretFile = config.<..>.path;
      #oidcIssuerPrivateKeyFile = config.<..>.path;
    };
    environmentVariables = { };
    settings = {
      server.port = 9092;
      theme = "dark";
      log.level = "debug";

      default_redirection_url = "https://auth.narbuto.lt";
      authentication_backend = {
        file.path = user_database;
      };
      session = {
        domain = "narbuto.lt";
        expiration = 3600;
        inactivity = 3600;
      };
      totp = {
        disable = false;
        issuer = "authelia.com";
        algorithm = "sha1";
        digits = 6;
        period = 30;
        skew = 1;
        secret_size = 32;
      };
      regulation = {
        max_retries = 3;
        find_time = "5m";
        ban_time = "15m";
      };

      access_control = {
        default_policy = "deny";
        rules = [
          {
            domain = [ "auth.narbuto.lt" ];
            policy = "bypass";
            resources = [
              "^/api$"
              "^/api/"
            ];
          }
          {
            domain = [ "git.narbuto.lt" ];
            policy = "bypass";
          }
          {
            domain = [ "plex.narbuto.lt" ];
            policy = "bypass";
          }
          {
            domain = [ "vault.narbuto.lt" ];
            policy = "bypass";
          }
          {
            domain = [ "*.narbuto.lt" "narbuto.lt" ];
            policy = "one_factor";
          }
        ];
      };

      storage.local = {
        path = "/var/lib/authelia-default/db.sqlite3";
      };

      notifier.filesystem = {
        filename = "/var/lib/authelia-default/notification.txt";
      };
    };
  };

  #######################
  ### --- Traefik --- ###
  #######################
  services.traefik = {
    enable = true;
    group = "docker";

    staticConfigOptions = {
      global = {
        checknewversion = false;
        sendanonymoususage = false;
      };
      api.dashboard = true;
      #api.insecure = true;
      providers = {
        docker = { };
      };
      entryPoints = {
        http = {
          address = ":80";
          http = {
            redirections = {
              entryPoint = {
                to = "https";
                scheme = "https";
              };
            };
          };
        };
        https = {
          address = ":443";
          http.tls = {
            certResolver = "letsEncrypt";
            domains.main = "narbuto.lt";
            domains.sans = "*.narbuto.lt";

          };
        };
      };
      certificatesResolvers = {
        # ts.tailscale = { };
        letsEncrypt.acme = {
          email = "simonas+acme@narbuto.lt";
          storage = "/var/lib/traefik/acme.json";
          dnsChallenge.provider = "cloudflare";
          dnsChallenge.delayBeforeCheck = 10;
          dnsChallenge.resolvers = [ "1.1.1.1:53" ];
        };
      };
      log.filePath = "/var/lib/traefik/application.log";
      log.level = "debug";
      accessLog.filePath = "/var/lib/traefik/access.log";

    };
    dynamicConfigOptions = {
      http = {
        middlewares = {
          authelia = {
            forwardAuth = {
              address = "http://localhost:9092/api/verify?rd=https://auth.narbuto.lt/";
              trustForwardHeader = true;
              authResponseHeaders = [
                "Remote-User"
                "Remote-Name"
                "Remote-Email"
                "Remote-Groups"
              ];
            };
          };
        };
        routers = {
          dashboard = {
            entryPoints = [ "https" ];
            middlewares = "authelia@file";
            rule = "Host(`traefik.narbuto.lt`)";
            service = "api@internal";
            tls.certResolver = "letsEncrypt";
          };
          authelia = {
            service = "authelia";
            rule = "Host(`auth.narbuto.lt`)";
            entryPoints = "https";
            tls.certResolver = "letsEncrypt";
          };
          gitea = {
            service = "gitea";
            rule = "Host(`git.narbuto.lt`)";
            entryPoints = "https";
            tls.certResolver = "letsEncrypt";
          };
          plex = {
            service = "plex";
            rule = "Host(`plex.narbuto.lt`)";
            entryPoints = "https";
            middlewares = "authelia@file";
            tls.certResolver = "letsEncrypt";
          };
          transmission = {
            service = "transmission";
            rule = "Host(`dl.narbuto.lt`)";
            entryPoints = "https";
            middlewares = "authelia@file";
            tls.certResolver = "letsEncrypt";
          };
          vaultwarden = {
            service = "vaultwarden";
            rule = "Host(`vault.narbuto.lt`)";
            entryPoints = "https";
            tls.certResolver = "letsEncrypt";
          };
        };
        services = {
          authelia.loadBalancer.servers = [{ url = "http://localhost:9092/"; }];
          vaultwarden.loadBalancer.servers = [{ url = "http://localhost:8000/"; }];
          plex.loadBalancer.servers = [{ url = "http://localhost:32400/"; }];
          transmission.loadBalancer.servers = [{ url = "http://localhost:9091/"; }];
          gitea.loadBalancer.servers = [{ url = "http://localhost:3000/"; }];
        };
      };
    };
  };

  # Set up cloudflare key
  systemd.services.traefik.environment = {
    #CF_API_EMAIL_FILE
    #CF_DNS_API_TOKEN_FILE
    CF_DNS_API_TOKEN = config.settings.services.traefik.cloudflareKey;
  };
  security.acme = {
    defaults.email = "simonas+acme@narbuto.lt";
    acceptTerms = true;
  };
  ###########################
  ### --- Vaultwarden --- ###
  ###########################
  users.users."${config.settings.usr.name}".extraGroups = [ "vaultwarden" ];
  services.vaultwarden = {
    enable = true;
    backupDir = "/srv/backups/vaultwarden";
    environmentFile = vaultwardenEnv;
    config = {
      DOMAIN = config.settings.services.vaultwarden.domain;
      SIGNUPS_ALLOWED = true;
    };
  };
  ####################
  ### --- Plex --- ###
  ####################
  services.plex = {
    enable = true;
    user = config.settings.usr.name;
    group = "users";
    openFirewall = true;
  };
  ############################
  ### --- Transmission --- ###
  ############################
  services.transmission = {
    enable = true;
    user = config.settings.usr.name;
    group = "users";
    settings.rpc-bind-address = "0.0.0.0";
    #settings.rpc-authentication-required = false;
    settings.rpc-host-whitelist-enabled = false;
    settings.download-dir = "/srv/media/movies";
  };
  #####################
  ### --- Gitea --- ###
  #####################
  services.gitea = {
    enable = true;
    package = unstable.gitea;
    settings.server = {
      SSH_DOMAIN = "kouti";
    };
    #user = "git";
    #group = "users";
  };
}
