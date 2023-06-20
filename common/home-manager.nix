{ config, pkgs, ... }:

let userName = "tpdns90321"; userEmail = "tpdns9032100@gmail.com"; in {
  zsh.enable = true;
  zsh.oh-my-zsh = {
    enable = true;
    theme = "robbyrussell";
  };

  zsh.initExtraFirst = ''
    # editor
    export EDITOR=nvim

    # react-native android
    export ANDROID_HOME=$HOME/Library/Android/sdk
    export PATH=$PATH:$ANDROID_HOME/emulator
    export PATH=$PATH:$ANDROID_HOME/platform-tools
  '';

  tmux = {
    enable = true;
    keyMode = "vi";
    extraConfig = ''
      # https://blog.sanctum.geek.nz/vi-mode-in-tmux/
      bind -T copy-mode-vi v send -X begin-selection
      bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "pbcopy"
      bind -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "pbcopy"

      # https://unix.stackexchange.com/questions/12032/how-to-create-a-new-window-on-the-current-directory-in-tmux
      bind '"' split-window -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"
      bind c new-window -c "#{pane_current_path}"
    '';
  };

  neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;

    plugins = with pkgs.vimPlugins; [
      lsp-zero-nvim
      nvim-lspconfig
      nvim-cmp
      cmp-buffer
      cmp-path
      cmp_luasnip
      cmp-nvim-lsp
    ];

    extraConfig = ''
      " white space
      set tabstop=2
      set shiftwidth=2
      set smartindent
      set expandtab

      " line
      set number

      " filetype
      syntax on
      filetype plugin indent on
      autocmd FileType python setlocal tabstop=4
    '';

    extraLuaConfig = ''
      -- lsp setup
      local lsp = require('lsp-zero').preset({
        manage_nvim_cmp = {
          set_sources = 'recommended'
        }
      })

      lsp.on_attach(function(client, bufnr)
        lsp.default_keymaps({buffer = bufnr})
      end)

      -- language servers
      require('lspconfig').rnix.setup({})

      require('lspconfig').tsserver.setup({})

      require('lspconfig').eslint.setup({
        single_file_support = false,
      })

      require('lspconfig').pyright.setup({})

      lsp.setup()
    '';
  };

  git = {
    enable = true;
    ignores = [ "*.swp" ];
    userName = userName;
    userEmail = userEmail;
    extraConfig = {
      core = {
        editor = "nvim";
      };
    };
  };
}
