{ nixpkgs-unstable, ... }:
let
  unstable = import nixpkgs-unstable {
    system = "x86_64-linux";
    config = { allowUnfree = true; };
  };
in
{
  services.home-assistant = {
    enable = true;
    package = (unstable.home-assistant.override {
      extraPackages = ps: with ps; [ psycopg2 ];
    }).overrideAttrs (old: {
      doInstallCheck = false;
    });
  };
  services.home-assistant.config =
  {
    frontend = { };

    http = {
      use_x_forwarded_for = true;
      trusted_proxies = [
        "127.0.0.1"
        "172.18.0.0/16"
        "::1"
      ];
    };

    recorder.db_url = "postgresql://@/hass";

    tado = { };
    sonos = {
      media_player.hosts = [ "192.168.178.60" ];
    };

    roomba = { };
    default_config = { };

    sensor = [{
      name = "random_joke";
      platform = "rest";
      json_attributes = "joke";
      resource = "https://icanhazdadjoke.com/";
      scan_interval = "3600";
      headers.Accept = "application/json";
    }];

    intent_script.TellJoke = {
      speech.text = ''{{ state_attr("sensor.random_joke", "joke") }}'';
      action = {
        service = "homeassistant.update_entity";
        entity_id = "sensor.random_joke";
      };
    };

  }; #services.home-assistant.config

  services.nginx = {
    virtualHosts."hass.narbuto.lt" = {
      useACMEHost = "narbuto.lt";
      forceSSL = true;
      extraConfig = ''
        proxy_buffering off;
      '';
      locations."/".extraConfig = ''
        proxy_pass http://127.0.0.1:8123;
        proxy_set_header Host $host;
        proxy_redirect http:// https://;
        proxy_http_version 1.1;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $connection_upgrade;
      '';
    };
  };
  services.postgresql = {
    enable = true;
    package = unstable.postgresql;
    ensureDatabases = [ "hass" ];
    ensureUsers = [{
      name = "hass";
      ensurePermissions = {
        "DATABASE hass" = "ALL PRIVILEGES";
      };
    }];
  };
}
