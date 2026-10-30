# hm base
{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./modules/starship.nix
    ./modules/helix
    ./modules/jujutsu
  ];
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  nixpkgs.config.allowUnfree = true;
  home.packages = with pkgs; [
    #system utils
    bitwarden-cli
    usbutils
    screen
    gopass
    pfetch
    jq
    bottom
  ];

  programs.rbw = {
    enable = true;
    settings = {
      email = config.settings.usr.email;
      lock_timeout = 86400;
      base_url = config.settings.services.vaultwarden.domain;
    };
  };
  programs.gpg.enable = true;
  # services
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
    enableDefaultConfig = false;
  };
  programs.bat = {
    enable = true;
    config = {
      theme = "TwoDark";
    };
  };
  programs.helix.enable = true;
  programs.jujutsu.enable = true;
  programs.diff-so-fancy = {
    enable = true;
    enableGitIntegration = true;
  };
  programs.git = {
    enable = true;
    signing.key = lib.mkIf (config.settings.usr.signingKey != "") config.settings.usr.signingKey;
    settings = {
      user.email = config.settings.usr.email;
      user.name = config.settings.usr.fullName;
      github.user = config.settings.usr.username;
      hub.protocol = "https";
      color.ui = true;
      pull.rebase = true;
      commit.gpgSign = true;
      init.defaultBranch = "main";
      fetch.prune = true;
      fetch.pruneTags = true;
      alias = {
        hist = "log --color --pretty=format:'%Cred%h%Creset - %s %C(yellow)%d%Creset %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
      };
    };
  };

  programs.starship.enable = true;
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    history = {
      size = 50000;
      save = 50000;
      ignoreDups = true;
    };
    shellAliases = {
      ls = "ls -F --color=auto";
      ll = "ls -lh";
      cat = "bat -p";
      grep = "grep --color=auto";
      feh = "feh -Z -.";
      history = "history -2000";
      find = "noglob find";
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
    initContent = ''
      ## This is the way... to traverse through history
      bindkey "^[OA" history-beginning-search-backward
      bindkey "^[OB" history-beginning-search-forward
      bindkey "^[[1;5D" backward-word
      bindkey "^[[1;5C" forward-word
      export RUST_SRC_PATH="${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}"
      export GOPATH="$HOME/dev/go"
      export PATH="$HOME/bin:$HOME/.cargo/bin:$GOPATH/bin:$PATH"
    '';
    sessionVariables = rec {
      ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE = "fg=3";

      EDITOR = "hx";
      VISUAL = EDITOR;
      GIT_EDITOR = EDITOR;
      # java apps on wayland like android-studio or arduino
      _JAVA_AWT_WM_NONREPARENTING = 1;
    };
    # envExtra
    # profileExtra
    # loginExtra
    # logoutExtra
    # localVariables
  };
}
