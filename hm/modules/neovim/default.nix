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
      # Collection of common configurations for the Nvim LSP client
      nvim-lspconfig
      lsp-status-nvim

      # A completion engine for neovim written in Lua.
      nvim-cmp

      # nvim-cmp source for buffer words.
      cmp-buffer

      # LSP completion source for nvim-cmp
      cmp-nvim-lsp

      # nvim-cmp source for filesystem paths
      cmp-path

      # nvim-cmp source for treesitter nodes
      cmp-treesitter

      # Snippet completion source for nvim-cmp
      cmp-vsnip


      # To enable more of the features of rust-analyzer, such as inlay hints and more!
      #rust-tools-nvim

      # Snippet engine
      vim-vsnip

      # languages
      vim-nix
      vim-markdown
      vim-go
      vim-toml
      vim-yaml
      vim-puppet

      # UI #################################################
      nvim-web-devicons
      #vim-airline
      lualine-nvim
      nerdtree
      nvim-compe
      nvim-treesitter

      # Editor Features ####################################
      vim-surround # cs"'
      vim-repeat # cs"'...
      hop-nvim
      #vim-commentary # gcap

      # Buffer / Pane / File Management ####################
      #fzf-vim # all the things
      # Fuzzy finder
      telescope-nvim

      tmux-complete-vim

      # Panes / Larger features ############################
      #tagbar # <leader>5
      # Git Integration
      vim-fugitive # Gblame
    ];
  }; # neovim
}
