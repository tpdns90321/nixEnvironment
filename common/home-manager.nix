{ config, pkgs, inputs, isDesktop ? false, ... }:

let
  userName = "tpdns90321";
  userEmail = "tpdns9032100@gmail.com";
  in {
  zsh.enable = true;
  zsh.oh-my-zsh = {
    enable = true;
    theme = "robbyrussell";
  };

  zsh.initContent = pkgs.lib.mkBefore (''
    # nix
    export NIXPKGS_ALLOW_UNFREE=1

    # editor
    export EDITOR=nvim
    export ESLINT_USE_FLAT_CONFIG=false
    '' + (if isDesktop then ''
    # direnv
    eval "$(direnv hook zsh)"

    # fnm node version manager
    eval "$(fnm env --use-on-cd)"
    '' else "") + ''

    # if exist '.env' in home, export exists environment variable.
    if [ -f ~/.env ]; then
      set -a
      if [ -f ~/.env ]; then
        . ~/.env
      fi
      set +a
    fi

    for file in $(ls ~/.env.*); do
      set -a
      if [ -f $file ]; then
        . $file
      fi
      set +a
    done

    function fscrypt-mosh() {
      host=$1
      shift
      ip=${"$"+"{host#*@}"}
      echo -n "Password: "
      read -s password
      export SSHPASS=$password
      PATH=$PATH:${pkgs.sshpass}/bin/ 
      pgrep -f "^ssh -Nf $ip$" || sshpass -e ssh -Nf $ip && mosh --ssh="sshpass -e ssh" $ip && pgrep -f "mosh-client .*$ip" || pkill -f "^ssh -Nf $ip$"
      unset SSHPASS
    }
  '' + (if pkgs.stdenv.hostPlatform.isDarwin then ''
# react-native android
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools

# Added by LM Studio CLI tool (lms)
if [ -f "$HOME/.lmstudio-home-pointer" ]; then
    LMSTUDIO_HOME="$(cat "$HOME/.lmstudio-home-pointer")"
else
    LMSTUDIO_HOME="$HOME/.lmstudio"
fi
export PATH="$PATH:$LMSTUDIO_HOME/bin"

function minikube() {
  PATH="$PATH:/opt/homebrew/bin/" KUBECONFIG=~/.kube/minikube-config command minikube "$@"
}

function minikube-kubectl() {
  PATH="$PATH:/opt/homebrew/bin/" KUBECONFIG=~/.kube/minikube-config command minikube kubectl -- "$@"
}
'' else ""));

  tmux = {
    enable = true;
    keyMode = "vi";
    extraConfig = ''
      set -g default-command "$SHELL"

      # https://blog.sanctum.geek.nz/vi-mode-in-tmux/
      bind -T copy-mode-vi v send -X begin-selection
      bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "pbcopy"
      bind -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "pbcopy"

      # https://unix.stackexchange.com/questions/12032/how-to-create-a-new-window-on-the-current-directory-in-tmux
      bind '"' split-window -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"
      bind c new-window -c "#{pane_current_path}"
    '';
    shell="$SHELL";
  };

  neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;

    plugins = (with pkgs.vimPlugins; [
      lsp-zero-nvim
      nvim-cmp
      nvim-lspconfig
      nvim-treesitter
      nvim-treesitter-parsers.html
      cmp-buffer
      cmp-path
      luasnip
      cmp_luasnip
      cmp-nvim-lsp
    ] ++ (if isDesktop then ([
      direnv-vim
      ale
    ] ++ (pkgs.callPackage (import ./customVimPlugins.nix inputs) {})) else []));

    extraPackages = with pkgs; [
      # lspconfig
      nixd
    ] ++ (if isDesktop then [
      gopls
      rust-analyzer
      ruff
      nodePackages_latest.vscode-langservers-extracted
      nodePackages_latest.typescript-language-server
      nodePackages_latest."@tailwindcss/language-server"
      pyright
      typescript
    ] else []);

    extraConfig = ''
      " white space
      set tabstop=2
      set shiftwidth=2
      set smartindent
      set expandtab

      " line
      set number

      " clipboard
      set clipboard^=unnamed,unnamedplus

      " filetype
      syntax on
      filetype plugin indent on
      autocmd FileType python setlocal tabstop=4

      " linting
      let g:ale_fixers = {
\        'javascript': [
\          'eslint',
\          'prettier',
\        ],
\        'typescript': [
\          'eslint',
\          'prettier',
\        ],
\        'javascriptreact': [
\          'eslint',
\          'prettier',
\        ],
\        'typescriptreact': [
\          'eslint',
\          'prettier',
\        ],
\        'python': [
\          'ruff',
\          'ruff_format',
\        ],
\        'go': [
\          'gofmt',
\        ],
\      }

      let g:ale_fix_on_save = 1
    '';

    extraLuaConfig = ''
      -- treesitter setup
      require'nvim-treesitter.configs'.setup {
        highlight = {
          enable = true,
        },
      }
      -- lsp setup
      local lsp = require('lsp-zero').preset({})

      lsp.on_attach(function(client, bufnr)
        lsp.default_keymaps({buffer = bufnr})
      end)

      -- language servers
      vim.lsp.enable('ts_ls')

      vim.lsp.enable('eslint')
      vim.lsp.config['eslint'] = {
        settings = {
          experimental = {
            useFlatConfig = nil,
          },
        },
      }

      vim.lsp.enable('nixd')
      '' + (if isDesktop then ''
      vim.lsp.enable('gopls')

      vim.lsp.enable('pyright')

      vim.lsp.enable('tailwindcss')

      vim.lsp.enable('rust_analyzer')
      vim.lsp.config['rust_analyzer'] = {
        settings = {
          ["rust-analyzer"] = {
            files = {
              excludeDirs = { ".direnv" },
            },
          }
        }
      }

      vim.lsp.enable('ruff')
      '' else "") + ''

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

  gh = {
    enable = true;

    settings = {
      editor = "nvim";
    };
  };

  alacritty = {
    enable = isDesktop;
    settings.font.size = 13;
    settings.terminal.shell = "${pkgs.zsh}/bin/zsh";
  };
}
