# hm base
{ config, pkgs, zshdfiles, nixpkgs-unstable, ... }:
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
    ./modules/neovim
  ];
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  nixpkgs.config.allowUnfree = true;
  home.packages = with pkgs; [
    #system utils
    usbutils
    screen
    pamixer
    gopass
    udiskie
    pfetch
    #dev
    rust-analyzer
    rustc cargo rustfmt cargo-edit clippy
    # rustup

    rnix-lsp
    (python39.withPackages(ps: with ps; [ pyserial intelhex termcolor crcmod requests ruamel_yaml pip yamllint flake8 setuptools ]))
    gitAndTools.gitflow
    jq
    gotop

  ];

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
      "git.narbuto.lt" = {
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
#      url = {
#        "ssh://git@github.com" = {
#          insteadOf = "https://github.com";
#        };
#      };
    };
  };
  programs.tmux = {
    enable = true;
    #shell = "\${pkgs.zsh}/bin/zsh";
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
    ## Set a nice prompt
    initExtra = ''
        ### =============== Git prompt variables ================ ###
        ZSH_THEME_GIT_PROMPT_BRANCH="%{\x1b[3m%}%{$fg[cyan]%}"
        ZSH_THEME_GIT_PROMPT_STAGED="%{$fg[green]%}%{¤%G%}"
        ZSH_THEME_GIT_PROMPT_CONFLICTS="%{$fg[blue]%}%{x%G%}"
        ZSH_THEME_GIT_PROMPT_CHANGED="%{$fg[red]%}%{+%G%}"
        ZSH_THEME_GIT_PROMPT_BEHIND="%{$fg[red]%}%{↓%G%}"
        ZSH_THEME_GIT_PROMPT_AHEAD="%{$fg[blue]%}%{↑%G%}"
        ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[red]%}%{…%G%}"
        ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[green]%}%{✔%G%}"
        ### =============== Git prompt variables ================ ###
        ## Set local and ssh prompts
        PROMPT='%F{red}[%F{blue}%*%F{red}]%f %F{yellow}%m%f %F{magenta}[%f%B%F{magenta}%1~%f%b%F{magenta}]%f %(!.%F{red}.%F{green})≫ %f$(git_super_status) '
        ## This is the way... to traverse through history
        bindkey "^[[A" history-beginning-search-backward
        bindkey "^[[B" history-beginning-search-forward
        '';
      initExtraBeforeCompInit = ''
        for f in ~/.zsh.d/*.zsh; do
          source "$f"
        done
        source ~/.zsh-git-prompt/zshrc.sh;
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
      GOPATH = "$HOME/development/go";
      PATH = "$HOME/bin:$GOPATH/bin:$PATH";
    };
    # envExtra
    # profileExtra
    # loginExtra
    # logoutExtra
    # localVariables
  };
  #repos
  home.file.".zsh-git-prompt".source = pkgs.fetchFromGitHub {
     owner = "simisimis";
     repo = "zsh-git-prompt";
     rev = "0a6c8b610e799040b612db8888945f502a2ddd9d";
     sha256 = "19x1gf1r6l7r6i7vhhsgzcbdlnr648jx8j84nk2zv1b8igh205hw";
  };
  home.file.".zsh.d".source = zshdfiles.outPath;
}
