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
      nnoremap <Tab> :bnext<CR>
      nnoremap <S-Tab> :bprevious<CR>

      set history=1000                  " Save a lot of history (default is 20)
      set clipboard=unnamedplus


      set visualbell                    " Use visual bell instead of a beep
      set ttyfast                       " Let vim know we have a fast terminal, regardless of $TERM

      set encoding=utf-8                " Set default file encoding to utf-8
      set paste                         " Set paste off

      set wildmode=longest,list         " Set shell like completion. to tab select add 'full'

      let g:airline#extensions#tabline#enabled = 1
      let g:airline#extensions#tabline#buffer_nr_show = 1

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
      vim-airline
      nerdtree
      nvim-lspconfig
      nvim-compe

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
      #vim-indent-object # >aI
      #vim-easy-align # vipga
      #vim-eunuch # :Rename foo.rb
      #vim-sneak
      #supertab
      #nerdtree

      # Buffer / Pane / File Management ####################
      fzf-vim # all the things

      # Panes / Larger features ############################
      #tagbar # <leader>5
      #vim-fugitive # Gblame
    ];
  };
}
