# siMONSTER host specific configuration
{
  config,
  lib,
  pkgs,
  unstable,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ../../nixos/initrd-unlock.nix
  ];

  # Narrower than the "@wheel" default set by mkHost; mkForce keeps it exact.
  nix.settings.trusted-users = lib.mkForce [ "root" config.settings.usr.name ];
  nix.settings.allowed-users = [ "root" config.settings.usr.name ];

  boot.initrd.kernelModules = [ "r8169" ];

  networking.interfaces.enp7s0.useDHCP = true;
  networking.interfaces.enp5s1.useDHCP = false;
  networking.firewall = {
    enable = true;
    allowedUDPPorts = [ config.services.tailscale.port ];
  };

  environment.systemPackages = with pkgs; [
    dmidecode
    docker-compose
    vulkan-tools
    unstable.llama-cpp-vulkan
  ];
  virtualisation.docker = {
    enable = true;
    storageDriver = "zfs";
  };

  services.llama-cpp = {
    enable = true;
    package = unstable.llama-cpp-vulkan;
    host = "0.0.0.0";
    port = 9931;
    openFirewall = true;
    modelsDir = "/var/lib/llama-cpp";
    modelsPreset = {
      "ThinkingCap-Qwen3.8-27B-Q4_K_M" = {
        ctx-size = "131072";
        reasoning = "on";
        reasoning-budget = "8192";
        spec-type = "draft-dflash,ngram-map-k4v";
        spec-draft-model = "/var/lib/llama-cpp/Qwen3.8-27B-DFlash2-Q4_K_M.gguf";
        spec-draft-n-max = "5";
        spec-draft-ngl = "all";
      };
      "Qwen3.8-27B-Q4_K_M" = {
        ctx-size = "131072";
        reasoning = "on";
        spec-type = "draft-dflash,ngram-map-k4v";
        spec-draft-model = "/var/lib/llama-cpp/Qwen3.8-27B-DFlash2-Q4_K_M.gguf";
        spec-draft-n-max = "5";
        spec-draft-ngl = "all";
      };
      "Qwen3.8-27B-UD-Q4_K_XL" = {
        ctx-size = "131072";
        reasoning = "on";
        reasoning-budget = "8192";
        spec-type = "draft-dflash,ngram-map-k4v";
        spec-draft-model = "/var/lib/llama-cpp/Qwen3.8-27B-DFlash2-Q4_K_M.gguf";
        spec-draft-n-max = "5";
        spec-draft-ngl = "all";
      };

      "Qwen3.5-4B-Q8_0" = {
        ctx-size = "262144";
        reasoning = "off";
        spec-type = "draft-mtp,ngram-mod";
      };
    };
    extraFlags = [
      "--load-mode"
      "mmap"
      "--flash-attn"
      "on"
      "--no-mmproj"

      "--parallel"
      "1"
      "--models-max"
      "1"
      "-ngl"
      "-1"
      "--cache-type-k"
      "q8_0"
      "--cache-type-v"
      "q8_0"

      "--cache-type-k-draft"
      "q8_0"
      "--cache-type-v-draft"
      "q8_0"
      "--no-reasoning-preserve"
    ];
    # extraFlags = [
    #   "--flash-attn"
    #   "on"
    #   "--no-mmproj"
    #   "--spec-type"
    #   "draft-mtp,ngram-mod"
    #   "--parallel"
    #   "1"
    #   "--models-max"
    #   "1"
    #   "-ngl"
    #   "all"
    #   "--cache-type-k"
    #   "q8_0"
    #   "--cache-type-v"
    #   "q8_0"

    #   "--cache-type-k-draft"
    #   "q8_0"
    #   "--cache-type-v-draft"
    #   "q8_0"
    # ];
  };

  systemd.services.llama-cpp = {
    environment = {
      XDG_CACHE_HOME = "/var/cache/llama-cpp";
      MESA_SHADER_CACHE_DIR = "/var/cache/llama-cpp";
    };

    serviceConfig.CacheDirectory = "llama-cpp";
  };

  security.pam.services.swaylock = { };

  services.udev.extraRules = ''
    # saleae logic analyser
    SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="21a9", ATTR{idProduct}=="1001", MODE="0666"
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="10:98:19:57:bc:9d", NAME="enp5s1"
  '';
}
