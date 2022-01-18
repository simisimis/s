{ nixpkgs-unstable, config, ... }:
let
  unstable = import nixpkgs-unstable {
    system = "x86_64-linux";
    config = { allowUnfree = true; };
  };
  dataDir = "/var/lib/zigbee2mqtt";
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
      latitude = "52.095525";
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
    sonos = {
      media_player.hosts = [ "192.168.178.60" ];
    };

    roomba = { };

    calendar = { };
    google = {
      client_id = "902077847980-5ioe3tre3lafmfn60fgf1tjldsol4ku2.apps.googleusercontent.com";
      client_secret = "arstarst";
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
    automation = [
      {
        alias = "living room tree off";
        trigger = {
          platform = "time";
          at = "22:00";
        };
        action = {
          type = "turn_off";
          device_id = "434ffceaa2edc88692f807839ac1bfe1";
          entity_id = "switch.living_room_plug";
          domain = "switch";
        };
      } #living room xmas auto off
      {
        alias = "living room tree on";
        trigger = {
          platform = "time";
          at = "7:00";
        };
        action = {
          type = "turn_on";
          device_id = "434ffceaa2edc88692f807839ac1bfe1";
          entity_id = "switch.living_room_plug";
          domain = "switch";
        };
      } #living room xmas auto on
      { alias = "attic xmas auto on";
        trigger = {
          platform = "time";
          at = "9:00";
        };
        action = {
          type = "turn_on";
          device_id = "8f71f657c883dce32f894908401dedba";
          entity_id = "switch.attic_plug";
          domain = "switch";
        };
      } #attic xmas auto on
      { alias = "attic xmas auto off";
        trigger = {
          platform = "time";
          at = "17:30";
        };
        action = {
          type = "turn_off";
          device_id = "8f71f657c883dce32f894908401dedba";
          entity_id = "switch.attic_plug";
          domain = "switch";
        };
      } #attic xmas auto off
    ]; # automation

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
    package = unstable.postgresql;
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
    package = unstable.zigbee2mqtt;
    settings = {
      permit_join = true;
      serial.port = "/dev/ttyACM0";
      homeassistant = true;
      mqtt = {
        server = "mqtt://localhost:1883";
        base_topic = "zigbee2mqtt";
        user = "hass";
        password = "arst";
#        include_device_information = true;
        client_id = "zigbee2mqtt";
      };
      advanced = {
        network_key = "GENERATE";
        log_level = "info";
      };
      frontend = {
        port = 8521;
      };
#      experimental = {
#        new_api = true;
#      };
    };
  };

  #state = [ "${dataDir}/devices.yaml" "${dataDir}/state.json" ];

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
