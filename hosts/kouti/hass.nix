{ config, pkgs, lib, ... }:
let
  dataDir = "/var/lib/zigbee2mqtt";
  zigbeeStick = "/dev/serial/by-id/usb-Silicon_Labs_slae.sh_cc2652rb_stick_-_slaesh_s_iot_stuff_00_12_4B_00_23_93_3E_19-if00-port0";

  format = pkgs.formats.yaml { };
  scripts = format.generate "scripts_manual.yaml" [{
    # close_shutters = {
    #   alias = "Bring down all Shutters";
    #   sequence = [
    #     {
    #       type = "close";
    #       device_id = "a0b97b59fef36eb323951194c5393f3d";
    #       entity_id = "7b445699cbabb24f62746d8dc62ff617";
    #       domain = "cover";
    #     }
    #     {
    #       type = "close";
    #       device_id = "ced64379cedb0489c4a893324634ff01";
    #       entity_id = "cd3054b952c75cb6aaf836088d6346aa";
    #       domain = "cover";
    #     }
    #   ];
    # };
    open_all_rollers = {
      alias = "Open all rollers";
      sequence = [{
        action = "cover.open_cover";
        data = { };
        target = {
          entity_id = "cover.all_rollers";
        };
      }];
      description = "Open all rollers";
    };
    close_all_rollers = {
      alias = "Close all rollers";
      sequence = [{
        action = "cover.close_cover";
        data = { };
        target = {
          entity_id = "cover.all_rollers";
        };
      }];
      description = "Close all rollers";
    };
  }];
  scenes = format.generate "scenes_manual.yaml" [ ];
  automations = format.generate "automations_manual.yaml" [
    {
      id = "1730826482621";
      alias = "Shutters up";
      description = "Lift up all shutters";
      triggers = [
        {
          trigger = "state";
          entity_id = "input_select.shutters_control";
          to = "Up";
        }
      ];
      actions = [{
        action = "script.open_shutters";
      }];
    }
    {
      id = "1730826482622";
      alias = "Shutters down";
      description = "Bring down all shutters";
      triggers = [
        {
          trigger = "state";
          entity_id = "input_select.shutters_control";
          to = "Down";
        }
      ];
      actions = [{
        action = "script.close_shutters";
      }];
    }
    {
      id = "1731010905879";
      alias = "rollerup";
      description = "Moving rollers up with buttons";
      triggers = [{
        domain = "mqtt";
        device_id = "b71f5e715ba07f7644fd251a67088a76";
        type = "action";
        subtype = "brightness_move_up";
        trigger = "device";
      }];
      conditions = [ ];
      actions = [
        {
          type = "open";
          device_id = "a0b97b59fef36eb323951194c5393f3d";
          entity_id = "7b445699cbabb24f62746d8dc62ff617";
          domain = "cover";
        }
      ];
      mode = "single";
    }
    {
      id = "1731010905880";
      alias = "rollerstop";
      description = "Moving rollers down with buttons";
      triggers = [{
        domain = "mqtt";
        device_id = "b71f5e715ba07f7644fd251a67088a76";
        type = "action";
        subtype = "brightness_move_down";
        trigger = "device";
      }];
      conditions = [ ];
      actions = [
        {
          type = "close";
          device_id = "a0b97b59fef36eb323951194c5393f3d";
          entity_id = "7b445699cbabb24f62746d8dc62ff617";
          domain = "cover";
        }
      ];
      mode = "single";
    }
    {
      id = "1733300096307";
      alias = "Close all rollers";
      description = "Close all rollers with IKEA left button";
      trigger = [
        {
          domain = "mqtt";
          device_id = "b71f5e715ba07f7644fd251a67088a76";
          type = "action";
          subtype = "arrow_left_click";
          trigger = "device";
        }
      ];
      condition = [ ];
      action = [
        {
          action = "script.close_all_rollers";
          metadata = { };
          data = { };
        }
      ];
      mode = "single";
    }
    {
      id = "1733300096308";
      alias = "Open all rollers";
      description = "Open all rollers with IKEA right button";
      trigger = [
        {
          domain = "mqtt";
          device_id = "b71f5e715ba07f7644fd251a67088a76";
          type = "action";
          subtype = "arrow_right_click";
          trigger = "device";
        }
      ];
      condition = [ ];
      action = [
        {
          action = "script.open_all_rollers";
          metadata = { };
          data = { };
        }
      ];
      mode = "single";
    }
    {
      id = "1640298949305";
      alias = "On motion light up the staircase";
      trigger = [
        {
          platform = "device";
          type = "motion";
          device_id = "5fe9cef4ff6223c14b3a3f89ae429adf";
          entity_id = "binary_sensor.motion_sensor_occupancy";
          domain = "binary_sensor";
          for = {
            hours = 0;
            minutes = 0;
            seconds = 1;
          };
        }
      ];
      condition = [
        {
          type = "is_illuminance";
          condition = "device";
          device_id = "5fe9cef4ff6223c14b3a3f89ae429adf";
          entity_id = "sensor.motion_sensor_illuminance_lux";
          domain = "sensor";
          below = "4";
        }
      ];
      action = [
        {
          action = "switch.turn_on";
          target = {
            entity_id = "switch.staircase_light_l2";
          };
        }
        {
          delay = {
            hours = 0;
            minutes = 0;
            seconds = 15;
            milliseconds = 0;
          };
        }
        {
          action = "switch.turn_off";
          target = {
            entity_id = "switch.staircase_light_l2";
          };
        }
      ];
      mode = "single";
    }
    # {
    #   id = "1731010905880";
    #   alias = "rollerstop";
    #   description = "Moving rollers stop";
    #   triggers = [{
    #     domain = "mqtt";
    #     device_id = "b71f5e715ba07f7644fd251a67088a76";
    #     type = "action";
    #     subtype = "brightness_stop";
    #     trigger = "device";
    #   }];
    #   conditions = [ ];
    #   actions = [
    #     {
    #       type = "stop";
    #       device_id = "a0b97b59fef36eb323951194c5393f3d";
    #       entity_id = "7b445699cbabb24f62746d8dc62ff617";
    #       domain = "cover";
    #     }
    #   ];
    #   mode = "single";
    # }
    # {
    #   id = "1705223239528";
    #   alias = "Plant light toggle";
    #   description = "";
    #   trigger = [
    #     { platform = "time"; at = "09:00:00"; id = "Morning"; }
    #     { platform = "time"; at = "19:00:00"; id = "Evening"; }
    #   ];
    #   condition = [ ];
    #   action = [{
    #     choose = [
    #       {
    #         conditions = [{ condition = "trigger"; id = [ "Morning" ]; }];
    #         sequence = [{ service = "light.turn_on"; target = { device_id = "6ef89c16b98084bfc4344652a0baf4e0"; }; data = { }; }];
    #       }
    #       {
    #         conditions = [{ condition = "trigger"; id = [ "Evening" ]; }];
    #         sequence = [{ service = "light.turn_off"; target = { device_id = "6ef89c16b98084bfc4344652a0baf4e0"; }; data = { }; }];
    #       }
    #     ];
    #   }];
    #   mode = "single";
    # }
    # {
    #   id = "1700036303";
    #   alias = "Kitchen light toggle";
    #   description = "";
    #   action = [{
    #     choose = [
    #       {
    #         conditions = [{ condition = "trigger"; id = [ "on" ]; }];
    #         sequence = [{ device_id = "dfab35ab8c823997e867512bbbafa532"; domain = "light"; entity_id = "a44ba48e3a06da7869a0bc6da4cf8f68"; type = "turn_on"; }];
    #       }
    #       {
    #         conditions = [{ condition = "trigger"; id = [ "off" ]; }];
    #         sequence = [{ device_id = "dfab35ab8c823997e867512bbbafa532"; domain = "light"; entity_id = "a44ba48e3a06da7869a0bc6da4cf8f68"; type = "turn_off"; }];
    #       }
    #     ];
    #   }];
    #   condition = [ ];
    #   mode = "single";
    #   trigger = [
    #     { device_id = "6f7e9b5860763551a83df23c1dbef7c4"; domain = "zha"; id = "on"; platform = "device"; subtype = "turn_on"; type = "remote_button_short_press"; }
    #     { device_id = "6f7e9b5860763551a83df23c1dbef7c4"; domain = "zha"; id = "off"; platform = "device"; subtype = "turn_off"; type = "remote_button_short_press"; }
    #   ];
    # }
  ];
  hassConfig = format.generate "configuration.yaml" {
    "automation manual" = "!include automations_manual.yaml";
    #"automation ui" = "!include automations.yaml";
    "scene manual" = "!include scenes_manual.yaml";
    #"scene ui" = "!include scenes.yaml";
    "script manual" = "!include scripts_manual.yaml";
    #"script ui" = "!include scripts.yaml";
    cover = [
      {
        platform = "group";
        name = "All rollers";
        unique_id = "cover.all_rollers";
        entities = [
          "cover.main_roller"
          "cover.office_main_roller"
          "cover.office_side_roller"
          "cover.office_wc_roller"
          "cover.kids_roller"
          "cover.kitchen_roller"
          "cover.main_side_roller"
        ];
      }
    ];
    alexa = {
      smart_home = {
        filter = {
          include_entities = [
            "cover.all_rollers"
          ];
          include_domains = [
            "cover"
          ];
        };
      };
    };
    default_config = { };
    http = {
      login_attempts_threshold = 5;
      use_x_forwarded_for = true;
      trusted_proxies = [
        "127.0.0.1"
        "::1"
      ];
    };
    frontend.themes = "!include_dir_merge_named themes";
    # cover = [
    #   {
    #     platform = "group";
    #     name = "Shutters";
    #     unique_id = "cover.shutters";
    #     entities = [
    #       "cover.kitchen_shutter"
    #       "cover.living_room_shutter_door"
    #       "cover.living_room_shutter_window"
    #     ];
    #   }
    # ];
    mqtt = {
      # binary_sensor = [
      #   {
      #     name = "Laundry State";
      #     device_class = "running";
      #     icon = "mdi:washing-machine";
      #     state_topic = "home/laundry/state";
      #     unique_id = "laundry_state";
      #   }
      # ];
    };
    homeassistant = {
      name = "Home";
      latitude = config.settings.hass.latitude;
      longitude = config.settings.hass.longitude;
      elevation = "220";
      time_zone = config.time.timeZone;
      unit_system = "metric";
      temperature_unit = "C";
      # customize = {
      #   "automation.doorbell".icon = "mdi:doorbell-video";
      # };
    };
    recorder.db_url = "postgresql://hass@/hass";
    # influxdb = {
    #   api_version = 2;
    #   host = "localhost";
    #   port = "8086";
    #   max_retries = 10;
    #   ssl = false;
    #   verify_ssl = false;
    #   token = secrets.influxdb.token;
    #   organization = "home";
    #   bucket = "hass";
    #   include = {
    #     entity_globs = [
    #       "sensor.current_*"
    #       "sensor.electricity_failures"
    #       "sensor.energy_*"
    #       "sensor.gas_*"
    #       "sensor.long_electricity_failures"
    #       "sensor.power_*"
    #       "sensor.voltage_*"
    #       "sensor.*_power"
    #       "sensor.*_energy"
    #     ];
    #   };
    # };
    input_select = {
      shutters_control = {
        name = "Shutters Control";
        options = [
          "close"
          "open"
          "stop"
        ];
        initial = "stop";
        icon = "mdi:window-shutter";
      };
    };
  };
  # hack to fix yaml functions
  configuration = pkgs.runCommand "configuration.yaml" { preferLocalBuild = true; } ''
    cp ${hassConfig} $out
    sed -i -e "s/'\!\([a-z_]\+\) \(.*\)'/\!\1 \2/;s/^\!\!/\!/;" $out
  '';
in
{
  networking.firewall.allowedUDPPorts = [ 5683 ];

  environment.systemPackages = with pkgs; [
    mosquitto
  ];

  services.zigbee2mqtt = {
    enable = true;
    inherit dataDir;
    settings = {
      permit_join = true;
      serial.port = zigbeeStick;
      serial.adapter = "zstack";
      homeassistant = lib.mkForce true;
      mqtt = {
        server = "mqtt://localhost:1883";
        base_topic = "zigbee2mqtt";
        user = "hass";
        password = config.settings.hass.zigbee2mqttPass;
        client_id = "zigbee2mqtt";
      };
      advanced = {
        network_key = [ 214 234 30 219 8 162 244 0 114 42 64 9 85 24 169 57 ];
        #network_key = [ 233 148 21 186 39 17 212 249 129 136 196 193 226 118 228 172 ];
        log_level = "info";
        channel = 15;
      };
      frontend = {
        port = 8521;
      };
      # devices = {
      #   "0x50325ffffed25ad6" = {
      #     friendly_name = "ikea_switch";
      #     availability = true;
      #   };
      #   "0xa4c1387b70a651ba" = {
      #     friendly_name = "office_main_roller";
      #   };
      #   "0x001788010bcd7c3d" = {
      #     friendly_name = "motion_sensor";
      #   };
      # };
    };
  };

  systemd.services.zigbee2mqtt = {
    # override automatic configuration.yaml deployment
    environment.ZIGBEE2MQTT_DATA = dataDir;
    after = [
      "mosquitto.service"
    ];
    before = [
      "home-assistant.service"
    ];
  };

  services.mosquitto = {
    enable = true;
    listeners = [{
      acl = [ "pattern readwrite #" ];
      omitPasswordAuth = true;
      settings.allow_anonymous = true;
    }];
  };

  services.postgresql = {
    enable = true;

    authentication = ''
      local hass hass ident map=ha
      local immich immich ident map=immich_map
    '';

    identMap = ''
      ha root hass
      immich_map simas immich
    '';

    ensureDatabases = [ "hass" "immich" ];

    ensureUsers = [
      {
        name = "hass";
        ensureDBOwnership = true;
      }
      {
        name = "immich";
        ensureDBOwnership = true;
      }
    ];
  };


  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      homeassistant = {
        volumes = [
          "/var/lib/homeassistant:/config"
          "${configuration}:/config/configuration.yaml"
          "${automations}:/config/automations_manual.yaml"
          "${scenes}:/config/scenes_manual.yaml"
          "${scripts}:/config/scripts_manual.yaml"
          "/run/dbus:/run/dbus:ro"
          "/run/postgresql:/run/postgresql:ro"
          "/media:/media"
        ];
        environment = {
          TZ = config.time.timeZone;
        };
        image = "ghcr.io/home-assistant/home-assistant:2024.10.4";
        extraOptions = [
          "--device=${zigbeeStick}"
          "--privileged"
          "--network=host"
        ];
      };
    };
  };
}
