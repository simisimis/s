# hm base
{ config, pkgs, nixpkgs-unstable, ... }:
let
  unstable = import nixpkgs-unstable {
    system = "x86_64-linux";
    config = {
      allowUnfree = true;
    };
  };
in
{
  imports = [
    ./modules
  ];
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  nixpkgs.config.allowUnfree = true;
  home.packages = with pkgs; [
    #system utils
    bitwarden-cli
    usbutils
    screen
    pamixer
    gopass
    udiskie
    pfetch
    #dev
    rust-analyzer
    rustc cargo rustfmt cargo-edit clippy cargo-watch bacon
    trunk wasm-pack wasm-bindgen-cli
    # rustup
    rnix-lsp
    (python39.withPackages(ps: with ps; [ pyserial intelhex termcolor crcmod requests ruamel_yaml pip yamllint flake8 setuptools ]))
    gitAndTools.gitflow
    jq
    gotop
    bottom

  ];

  programs.rbw = {
    enable = true;
    settings = {
      email = config.settings.usr.email;
      lock_timeout = 86400;
      base_url = config.settings.services.bitwarden.baseUrl;
    };
  };
  programs.gpg.enable = true;
  systemd.user.targets.tray = {
		Unit = {
			Description = "Home Manager System Tray";
			Requires = [ "graphical-session-pre.target" ];
		};
	};
  # services
  services.udiskie = {
    enable = true;
    tray = "never";
  };
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultOptions = [ "-e" ];
  };
  programs.ssh = {
    enable = true;
    matchBlocks = {
      "backute" = {
        user = "git";
        identityFile = config.settings.usr.ssh.gitea.identityFile;
        extraOptions = {
          AddKeysToAgent = "yes";
          PubKeyAuthentication = "yes";
        };
      };
    };
  };
  programs.bat = {
    enable = true;
    config = {
      theme = "DarkNeon";
    };
  };
  programs.git = {
    enable = true;
    extraConfig = {
      hub.protocol = "https";
      color.ui = true;
      pull.rebase = true;
    };
  };
  programs.zellij.enable = true;

  programs.tmux = {
    enable = true;
    terminal = "screen-256color";
    shortcut = "s";
    historyLimit = 30000;
    baseIndex = 1;
    extraConfig = ''
      set-window-option -g mode-keys vi

      # mouse select copy buffer
      set -g mouse on

      # bind broadcast toggle
      bind-key b setw synchronize-panes

      # clear scrollbuffer
      bind-key C-l send-keys C-l \; clear-history

      # format status bar
      set -g status-left "#[fg=colour105,bg=colour241,bold] #S #[fg=colour123,bg=colour241]☵ "
      set -g status-right ""
      setw -g window-status-format "#[fg=colour105,bg=colour241] #I#[fg=colour105,bg=colour241] #W ⋮"
      setw -g window-status-current-format "#[fg=colour123,bg=colour241]|#[fg=colour123,bg=colour241] ⋲ #[fg=colour123,Bg:=colour241] #W #[fg=colour123,bg=colour241] ⋺ |"
      set -g status-bg "colour241"

      # A temp file to fiddle with tmux conf
      bind r source-file ~/.config/tmux/fiddle.conf
      '';
  };
  programs.starship.enable = true;
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableAutosuggestions = true;
    history = {
      size = 50000;
      save = 50000;
      ignoreDups = true;
    };
    #shellAliases = import ./home/aliases.nix;
    shellAliases = {
      ls="ls -F --color=auto";
      ll="ls -lh";
      cat="bat -p";
      grep="grep --color=auto";
      feh="feh -Z -.";
      history="history -2000";
      find="noglob find";
    };
    defaultKeymap = "emacs";
    plugins = [
      {
        name = "zsh-autosuggestions";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-autosuggestions";
          rev = "v0.7.0";
          sha256 = "sha256-KLUYpUu4DHRumQZ3w59m9aTW6TBKMCXl2UcKi4uMd7w=";
        };
      }
      {
        name = "zsh-syntax-highlighting";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-syntax-highlighting";
          rev = "be3882aeb054d01f6667facc31522e82f00b5e94";
          sha256 = "0w8x5ilpwx90s2s2y56vbzq92ircmrf0l5x8hz4g1nx3qzawv6af";
        };
      }
    ];
    initExtra = ''
        ## This is the way... to traverse through history
        bindkey "^[OA" history-beginning-search-backward
        bindkey "^[OB" history-beginning-search-forward
        export RUST_SRC_PATH="${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}"
        export GOPATH="$HOME/dev/go"
        export PATH="$HOME/bin:$HOME/.cargo/bin:$GOPATH/bin:$PATH"
        '';
    sessionVariables = rec {
      #NVIM_TUI_ENABLE_TRUE_COLOR = "1";
      #HOME_MANAGER_CONFIG = /b/etc/nix/home.nix;
      ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE = "fg=3";
      #DEV_ALLOW_ITERM2_INTEGRATION = "1";

      EDITOR = "nvim";
      VISUAL = EDITOR;
      GIT_EDITOR = EDITOR;
      #BAT_THEME="dark_neon";
      # java apps on wayland like android-studio or arduino
      _JAVA_AWT_WM_NONREPARENTING=1;
    };
    # envExtra
    # profileExtra
    # loginExtra
    # logoutExtra
    # localVariables
  };
}
