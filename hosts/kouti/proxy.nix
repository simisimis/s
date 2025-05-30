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
  immichEnv = builtins.toFile "immich.env" ''
    DB_PASSWORD="${config.settings.services.immich.dbPass}"
  '';

in
{
  ###########################
  ### --- Cloudflared --- ###
  ###########################
  services.cloudflared = {
    enable = true;
    tunnels."${config.settings.hw.hostName}" = {
      credentialsFile =
        builtins.toFile "credentialsFile.json" (builtins.toJSON config.settings.services.cloudflared.tunnelCredentials);
      ingress = {
        "narbuto.lt" = { service = "https://localhost:443"; };
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
      server.address = "tcp://:9092";
      theme = "dark";
      log.level = "debug";

      authentication_backend = {
        file.path = user_database;
      };
      session = {
        expiration = 3600;
        inactivity = 3600;
        cookies = [{
          domain = "narbuto.lt";
          authelia_url = "https://auth.narbuto.lt";
          default_redirection_url = "https://narbuto.lt";
        }];
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
            domain = [ "*.narbuto.lt" "narbuto.lt" ];
            policy = "one_factor";
            resources = [
              "^/.*"
            ];
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
            entryPoints = [ "http" "https" ];
            tls.certResolver = "letsEncrypt";
          };
          plex = {
            service = "plex";
            rule = "Host(`plex.narbuto.lt`)";
            entryPoints = [ "http" "https" ];
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
          hass = {
            service = "hass";
            rule = "Host(`ha.narbuto.lt`)";
            entryPoints = "https";
            #middlewares = "authelia@file";
            tls.certResolver = "letsEncrypt";
          };
          z2m = {
            service = "z2m";
            rule = "Host(`z2m.narbuto.lt`)";
            entryPoints = "https";
            middlewares = "authelia@file";
            tls.certResolver = "letsEncrypt";
          };
          esp = {
            service = "esp";
            rule = "Host(`esp.narbuto.lt`)";
            entryPoints = "https";
            middlewares = "authelia@file";
            tls.certResolver = "letsEncrypt";
          };
          img = {
            service = "img";
            rule = "Host(`img.narbuto.lt`)";
            entryPoints = "https";
            #middlewares = "authelia@file";
            tls.certResolver = "letsEncrypt";
          };
        };
        services = {
          authelia.loadBalancer.servers = [{ url = "http://localhost:9092/"; }];
          vaultwarden.loadBalancer.servers = [{ url = "http://localhost:8000/"; }];
          plex.loadBalancer.servers = [{ url = "http://localhost:32400/"; }];
          transmission.loadBalancer.servers = [{ url = "http://localhost:9091/"; }];
          gitea.loadBalancer.servers = [{ url = "http://localhost:3000/"; }];
          hass.loadBalancer.servers = [{ url = "http://localhost:8123/"; }];
          z2m.loadBalancer.servers = [{ url = "http://localhost:8521/"; }];
          esp.loadBalancer.servers = [{ url = "http://localhost:6052/"; }];
          img.loadBalancer.servers = [{ url = "http://localhost:2283/"; }];
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
  #######################
  ### --- ESPHome --- ###
  #######################
  services.esphome.enable = true;
  services.esphome.usePing = true;

  #######################
  ### --- Immich  --- ###
  #######################
  services.immich = {
    enable = true;
    user = "simas";
    group = "users";
    mediaLocation = "/srv/media/immich";
    secretsFile = "${immichEnv}";
    database.host = "127.0.0.1";
    machine-learning.environment = {
      MACHINE_LEARNING_CACHE_FOLDER = "/var/cache/immich";
      MPLCONFIGDIR = "/var/cache/immich/matplotlib";
      HF_TOKEN_PATH = "/var/cache/immich/huggingface/token";
    };
  };

  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      gitwitt = {
        image = "simisimis/gitwitt:0.2.0";
        extraOptions = [
          "--security-opt=no-new-privileges"
        ];
        environment = { };
        volumes = [ ];
        labels = {
          "traefik.enable" = "true";
          "traefik.http.routers.gitwitt.rule" = "Host(`gitwitt.narbuto.lt`)";
          "traefik.http.routers.gitwitt.entryPoints" = "https";
          "traefik.http.routers.gitwitt.tls.certresolver" = "letsEncrypt";
          "traefik.http.routers.gitwitt.service" = "gitwitt";
          "traefik.http.services.gitwitt.loadbalancer.server.port" = "8080";
        };
      };
      narbuto = {
        image = "narbuto:0.1.3";
        extraOptions = [
          "--security-opt=no-new-privileges"
        ];
        environment = { };
        volumes = [ ];
        labels = {
          "traefik.enable" = "true";
          "traefik.http.routers.narbuto.rule" = "Host(`narbuto.lt`)";
          "traefik.http.routers.narbuto.entryPoints" = "https";
          "traefik.http.routers.narbuto.tls.certresolver" = "letsEncrypt";
          "traefik.http.routers.narbuto.service" = "narbuto";
          "traefik.http.services.narbuto.loadbalancer.server.port" = "8080";
        };
      };
    };
  };
}
