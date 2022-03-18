{
  services.home-assistant.config.scene = [
    { id = "1643439197572";
      name = "living_disco";
      icon = "mdi:chandelier";
      entities = {
        "light.livingroom_lamp1" = {
          min_mireds = "250";
          max_mireds = "454";
          effect_list = [
            "blink"
            "breathe"
            "okay"
            "channel_change"
            "finish_effect"
            "stop_effect"
          ];
          supported_color_modes = [
            "color_temp"
            "xy"
          ];
          color_mode = "xy";
          brightness = "255";
          hs_color = [
            "224.916"
            "70.196"
          ];
          rgb_color = [
            "76"
            "121"
            "255"
          ];
          xy_color = [
            "0.164"
            "0.132"
          ];
          color = {
            x = "0.164";
            y = "0.132";
          };
          power_on_behavior = "on";
          update = {
            state = "idle";
          };
          update_available = false;
          friendly_name = "livingroom_lamp1";
          supported_features = "63";
          state = "on";
        };
        "select.livingroom_lamp1_power_on_behavior" = {
          options = [
            "off"
            "previous"
            "on"
          ];
          brightness = "254";
          color = {
            x = "0.164";
            y = "0.132";
          };
          color_mode = "xy";
          color_temp = "170";
          power_on_behavior = "on";
          update = {
            state = "idle";
          };
          update_available = false;
          icon = "mdi:power-settings";
          friendly_name = "livingroom_lamp1_power_on_behavior";
          state = "on";
        };
      };
    }
  ];
}
