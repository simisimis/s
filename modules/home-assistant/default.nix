{ config, ... }:
let
  dataDir = "/var/lib/zigbee2mqtt";
in
{
  imports = [
    ./scenes.nix
  ];

  services.home-assistant.enable = true;
  services.home-assistant.extraPackages = python3Packages: with python3Packages; [ psycopg2 ];
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
    history.exclude = {
      domains = [
        "automation"
        "updater"
      ];
    };
    recorder.db_url = "postgresql://@/hass";

    homeassistant = {
      name = "Home";
      time_zone = config.time.timeZone;
      latitude = "22.095525";
      longitude = "5.053437";
      elevation = "5";
      unit_system = "metric";
      temperature_unit = "C";
    };
    mqtt = {
      broker = "localhost";
      port = 1883;
      username = "hass";
      password = "arst";
    };
    tado = { };
    zha = { };
    sonos = {
      media_player.hosts = [ "192.168.178.60" ];
    };

    roomba = { };

    calendar = { };
    google = {
      client_id = "902077847980-5ioe3tre3lafmfn60fgf1tjlds.apps.googleusercontent.com";
      client_secret = "GOCSPX-wFMfa0Vpny6cEW1fUZAU";
      calendar_access = "read_write";
    };
    shelly = {};
    default_config = { };

    sensor = [{
      name = "random_joke";
      platform = "rest";
      json_attributes = "joke";
      resource = "https://icanhazdadjoke.com/";
      scan_interval = "3600";
      headers.Accept = "application/json";
      value_template = "{{ value_json.joke }}";
    }];

    intent_script.TellJoke = {
      speech.text = ''{{ state_attr("sensor.random_joke", "joke") }}'';
      action = {
        service = "homeassistant.update_entity";
        entity_id = "sensor.random_joke";
      };
    };
    "automation manual" = [
      { alias = "kitchen lights auto on";
        trigger = {
          platform = "sun";
          event = "sunset";
          offset = "0";
        };
        action = {
          type = "turn_on";
          device_id = "8f71f657c883dce32f894908401dedba";
          entity_id = "switch.kitchen_plug";
          domain = "switch";
        };
      } #kitchen lights auto on
      { alias = "kitchen lights auto off";
        trigger = {
          platform = "sun";
          event = "sunset";
          offset = "+02:00:00";
        };
        action = {
          type = "turn_off";
          device_id = "8f71f657c883dce32f894908401dedba";
          entity_id = "switch.kitchen_plug";
          domain = "switch";
        };
      } #kitchen lights auto off
    ]; # automation manual
    "automation ui" = "!include automations.yaml";

  }; #services.home-assistant.config

  services.nginx = {
    virtualHosts."ha.narbuto.lt" = {
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
    ensureDatabases = [ "hass" ];
    ensureUsers = [{
      name = "hass";
      ensurePermissions = {
        "DATABASE hass" = "ALL PRIVILEGES";
      };
    }];
  };
  services.zigbee2mqtt = {
    enable = true;
    inherit dataDir;
    settings = {
      permit_join = false;
      serial.port = "/dev/ttyUSB0";
      homeassistant = true;
      mqtt = {
        server = "mqtt://localhost:1883";
        base_topic = "zigbee2mqtt";
        user = "hass";
        password = "DCSde40";
        client_id = "zigbee2mqtt";
      };
      advanced = {
        network_key = [ 233 148 21 186 39 17 212 249 129 136 196 193 226 118 228 172 ];
        log_level = "info";
        channel = 15;
      };
      frontend = {
        port = 8521;
      };
    };
  };

  systemd.services.zigbee2mqtt = {
    # override automatic configuration.yaml deployment
    environment.ZIGBEE2MQTT_DATA = dataDir;
    after = [
      "home-assistant.service"
      "mosquitto.service"
      "network-online.target"
    ];
  };

  services.mosquitto = {
    enable = true;
    persistence = false;
    settings.max_keepalive = 60;
    listeners = [
      {
        port = 1883;
        omitPasswordAuth = false;
        users.sensor = {
          hashedPassword = "$7$101$FtTAxI3zCSJetIhA$of8FT/7VKQ+80dhqEA/nVtdNvNp9S7V7ryYn0WbbyA4zqtpBeEDOGMMkW8vpLYKqZFHoOAUtvwZ98GfbDN2OAA==";
          acl = [ "readwrite #" ];
        };
        users.hass = {
          hashedPassword = "$7$101$bs680qEFWF7ScglA$ndAJ34vTKJ8dVSH2vhQiSnFlzlM2gUVi1u/6W9YZTtD8jeO+csNFe+N91EZTE/i8vmaVrIVrQYytCeSuGuyY6A==";
          acl = [ "readwrite #" ];
        };
        settings = {
          allow_anonymous = false;
        };
      }
    ];
  };
}
