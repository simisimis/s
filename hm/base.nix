# hm base
{ config, pkgs, lib, ... }:
let
  unstable = import <nixos-unstable> { config.allowUnfree = true; };
in
{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  nixpkgs.config.allowUnfree = true;
  home.packages = with pkgs; [
    xclip

    # dev
    (python38.withPackages(ps: with ps; [ termcolor crcmod requests ruamel_yaml pip yamllint flake8 setuptools ]))
    unstable.go unstable.golint dep
    exercism
    unstable.prusa-slicer
 
    #fonts
    source-code-pro
    meslo-lg

    #terminal
    termite

    #web
    firefox
    chromium

    #system manage
    pulseaudio
    pavucontrol
    pamixer

    #utils
    cifs-utils
    filezilla
    transmission-gtk
    gopass
    freerdp
    speedcrunch
    scrot
    flameshot

    #media
    gthumb
    digikam
    feh
    gimp
    obs-studio
    #ffmpeg-full
    mpv-unwrapped
    spotify
    calibre
    wally-cli
  ];

  programs.zathura.enable = true;
  programs.rofi.enable = true;
  programs.rofi.theme = "Pop-Dark.rasi";
  programs.termite = {
    enable = true;
    font = "Meslo LG S DZ 12";
    backgroundColor = "rgba(63, 63, 63, 0.5)";
    scrollbackLines = 10000;
    foregroundColor = "dedede";
    foregroundBoldColor = "dedede";
    cursorColor = "#6f6f6f";
    colorsExtra = ''
      # black
      color0  = #2e3436
      color8  = #555753

      # red
      color1  = #fc3e3e
      color9  = #f06464

      # green
      color2  = #66b31e`
      color10 = #8ae234

      # yellow
      color3  = #f6d922
      color11 = #fce94f

      # blue
      color4  = #5183c4
      color12 = #729fcf

      # magenta
      color5  = #c36ccf
      color13 = #c164b6

      # cyan
      color6  = #19a5a7
      color14 = #429bf1

      # white
      color7  = #d3d7cf
      color15 = #eeeeec

    '';
  };

  programs.vscode = {
    enable = true;
    #package = unstable.vscode-with-extensions;
    #extensions = [
    #  vscode-extensions.ms-vscode.Go
    #];
  };

  programs.gpg.enable = true;
  # services
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    pinentryFlavor = "gtk2";
  };
  xdg = {
    configFile."mimeapps.list".force = true;
    configFile."obs-studio/plugins/obs-v4l2sink/bin/64bit/obs-v4l2sink.so".source =
    "${pkgs.obs-v4l2sink}/share/obs/obs-plugins/v4l2sink/bin/64bit/v4l2sink.so";
    mimeApps = {
      enable = true;
      associations.added = {
        "x-scheme-handler/magnet"="userapp-transmission-gtk-XEE0Y0.desktop";
      };
      defaultApplications = {
        "text/html" = "browser";
        "x-scheme-handler/http"="browser.desktop";
        "x-scheme-handler/https"="browser.desktop";
        "x-scheme-handler/about"="browser.desktop";
        "x-scheme-handler/unknown"="browser.desktop";
        "x-scheme-handler/magnet"="userapp-transmission-gtk-XEE0Y0.desktop";
      };
    };
  };
  programs.ssh = {
    enable = true;
    matchBlocks = {
      "192.168.178.100" = {
        user = "simas";
      };
      "git.narbuto.lt" = {
        user = "git";
        identityFile = "/home/simas/.ssh/id_rsa_siMOHCTP_gitea";
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
      url = {
        "ssh://git@github.com" = {
          insteadOf = "https://github.com";
        };
      };
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
          rev = "v0.6.3";
          sha256 = "1h8h2mz9wpjpymgl2p7pc146c1jgb3dggpvzwm9ln3in336wl95c";
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

      GOPATH = "$HOME/development/go";
      PATH = "$HOME/.bin:$GOPATH/bin:$PATH";
    };
    # envExtra
    # profileExtra
    # loginExtra
    # logoutExtra
    # localVariables
  };
  programs.neovim = {
    enable = true;
    vimAlias = true;
    viAlias = true;
    vimdiffAlias = true;
    #extraConfig = builtins.readFile ./home/extraConfig.vim;
    extraConfig = ''
      colorscheme gruvbox
      silent !mkdir -p ~/.cache/vim/{backup,tmp,undo} > /dev/null 2>&1
      if &diff
        colorscheme industry
      endif
      " set nocompatible
      set hidden                        " Allow buffer switching without saving
      set backup                        " Make a backup of the file before saving
      set backupdir=~/.cache/vim/backup " Directory to write backups to (should exist)
      set directory=~/.cache/vim/tmp    " No more .sw[a-z] (swap) files all over the place (should exist)
      set history=1000                  " Save a lot of history (default is 20)
      if has('persistent_undo')
        set undofile                    " Use persistent undo file
        set undodir=~/.cache/vim/undo   " Directory to write undo files to (should exist)
        set undolevels=1000             " Maximum number of changes that can be undone
        set undoreload=10000            " Maximum number of lines to save for undo on buffer reload
      endif

      set tabstop=2                     " Number of spaces that equals a tab
      set shiftwidth=2                  " Number of spaces to shift (e.g. >> and <<) with
      set expandtab                     " Insert spaces instead of tabs
      set autoindent                    " Automatically indent to the previous lines' indent level

      set visualbell                    " Use visual bell instead of a beep
      set ttyfast                       " Let vim know we have a fast terminal, regardless of $TERM

      set encoding=utf-8                " Set default file encoding to utf-8
      set paste                         " Set paste off
      '';
    plugins = with pkgs.vimPlugins; [
      # Syntax / Language Support ##########################
      vim-nix
      vim-go
      vim-toml
      vim-yaml

      # UI #################################################
      gruvbox # colorscheme
      onedark-vim
      #industry
      # vim-gitgutter # status in gutter
      # vim-devicons
      # vim-airline

      # Editor Features ####################################
      vim-surround # cs"'
      vim-repeat # cs"'...
      #vim-commentary # gcap
      # vim-ripgrep
      #vim-indent-object # >aI
      #vim-easy-align # vipga
      #vim-eunuch # :Rename foo.rb
      #vim-sneak
      #supertab
      #nerdtree

      # Buffer / Pane / File Management ####################
      #fzf-vim # all the things

      # Panes / Larger features ############################
      #tagbar # <leader>5
      #vim-fugitive # Gblame
    ];
  };
  #repos
  home.file.".zsh-git-prompt".source = pkgs.fetchFromGitHub {
     owner = "simisimis";
     repo = "zsh-git-prompt";
     rev = "0a6c8b610e799040b612db8888945f502a2ddd9d";
     sha256 = "19x1gf1r6l7r6i7vhhsgzcbdlnr648jx8j84nk2zv1b8igh205hw";
  };
  home.file.".zsh.d".source = builtins.fetchGit {
    url = "ssh://git@git.narbuto.lt:2203/simas/zshd.git";
    ref = "master";
  };
  home.stateVersion = "20.09";
}
