{ config, pkgs, inputs, ... }:

let
  userName = "tpdns90321";
  userEmail = "tpdns9032100@gmail.com";
  in {
  zsh.enable = true;
  zsh.oh-my-zsh = {
    enable = true;
    theme = "robbyrussell";
  };

  zsh.initExtraFirst = ''
    # editor
    export EDITOR=nvim
    export PATH=$PATH:${pkgs.nodePackages."@astrojs/language-server".outPath}/bin

    # react-native android
    export ANDROID_HOME=$HOME/Library/Android/sdk
    export PATH=$PATH:$ANDROID_HOME/emulator
    export PATH=$PATH:$ANDROID_HOME/platform-tools

    # podman aliasing
    alias docker=podman
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

    plugins = (with pkgs.vimPlugins; [
      lsp-zero-nvim
      nvim-lspconfig
      nvim-cmp
      cmp-buffer
      cmp-path
      luasnip
      cmp_luasnip
      cmp-nvim-lsp
    ]) ++ (pkgs.callPackage (import ./customVimPlugins.nix inputs) {});

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

      " astro
      let g:astro_typescript = 'enable'
    '';

    extraLuaConfig = ''
      -- lsp setup
      local lsp = require('lsp-zero').preset({})

      lsp.on_attach(function(client, bufnr)
        lsp.default_keymaps({buffer = bufnr})
      end)

      -- language servers
      require('lspconfig').rnix.setup({})

      require('lspconfig').tsserver.setup({})

      require('lspconfig').eslint.setup({
        single_file_support = false,
      })

      require('lspconfig').astro.setup({})

      require('lspconfig').tailwindcss.setup({})

      require('lspconfig').pyright.setup({})

      lsp.setup()

      vim.diagnostic.config({
        virtual_text = true,
      })

      local cmp = require('cmp')
      local cmp_action = require('lsp-zero').cmp_action()

      cmp.setup({
        sources = {
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'buffer' },
          { name = 'path' },
        },
        mapping = {
          ['<C-p>'] = cmp.mapping(function()
            if cmp.visible() then
              cmp.select_prev_item(cmp_select_opts)
            else
              cmp.complete()
            end
          end),
          ['<C-n>'] = cmp.mapping(function()
            if cmp.visible() then
              cmp.select_next_item(cmp_select_opts)
            else
              cmp.complete()
            end
          end),
          ['<CR>'] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
          }),
        },
        snippet = {
          expand = function(args)
            require('luasnip').lsp_expand(args.body)
          end,
        },
        window = {
          documentation = cmp.config.window.bordered(),
          completion = cmp.config.window.bordered(),
        },
        formatting = {
          fields = {'abbr', 'menu', 'kind'},
          format = function(entry, item)
            local short_name = {
              nvim_lsp = 'LSP',
              nvim_lua = 'nvim'
            }

            local menu_name = short_name[entry.source.name] or entry.source.name

            item.menu = string.format('[%s]', menu_name)
            return item
          end,
        },
      })
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
      pull.rebase = true;
    };
  };
}
