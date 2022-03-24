{ pkgs, nixpkgs-unstable, ... }@inputs:
let
  initLua = builtins.readFile ./init.lua;
  unstable = import nixpkgs-unstable {
    system = "x86_64-linux";
    config = {
      allowUnfree = true;
    };
  };
in
{
  programs.neovim = {
    enable = true;
    package = unstable.neovim-unwrapped;
    vimAlias = true;
    viAlias = true;
    vimdiffAlias = true;
    #extraConfig = builtins.readFile ./home/extraConfig.vim;
    extraConfig = ''
      lua << EOF
      ${initLua}
      EOF
      '';
    plugins = with pkgs.vimPlugins; [
      # Syntax / Language Support ##########################
      vim-nix
      vim-go
      vim-toml
      vim-yaml
      vim-puppet
      vim-airline
      nerdtree
      nvim-lspconfig
      nvim-compe

      indentLine # show indentlines
      vim-vinegar
      # UI #################################################
      tokyonight-nvim
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
      #vim-indent-object # >aI
      #vim-easy-align # vipga
      #vim-eunuch # :Rename foo.rb
      #vim-sneak
      #supertab
      #nerdtree

      # Buffer / Pane / File Management ####################
      fzf-vim # all the things
      tmux-complete-vim

      # Panes / Larger features ############################
      #tagbar # <leader>5
      # Git Integration
      vim-fugitive # Gblame
    ];
  };
}
