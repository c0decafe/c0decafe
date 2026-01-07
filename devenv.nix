{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: let
  name = "c0decafe";
  version = "0.1.0";
  isDev = !config.container.isBuilding;

  # Configure nixvim with our custom config
  nixvim' = inputs.nixvim.legacyPackages.${pkgs.stdenv.hostPlatform.system};
  nvim = nixvim'.makeNixvimWithModule {
    inherit pkgs;
    module = _: {
      viAlias = true;
      vimAlias = true;

      # Performance options for remote SSH
      opts = {
        updatetime = 100; # Faster update time (default 4000ms)
        timeoutlen = 300; # Faster key sequence timeout (default 1000ms)
        redrawtime = 1500; # Syntax highlighting timeout for large files
        synmaxcol = 200; # Don't highlight very long lines
        scrolljump = 5; # Lines to scroll when cursor leaves screen
        pumblend = 0; # Disable popup transparency
        winblend = 0; # Disable window transparency
      };

      plugins = {
        # LSP Configuration
        lsp = {
          enable = true;
          servers = {
            bashls.enable = true;
            biome.enable = true;
            copilot.enable = true;
            jsonls.enable = true;
            lua_ls.enable = true;
            nixd.enable = true;
            ts_ls.enable = true;
          };
        };

        # Treesitter for syntax highlighting
        treesitter = {
          enable = true;
          settings = {
            indent.enable = true;
            # Disable incremental selection for better remote performance
            incremental_selection.enable = false;
            ensure_installed = ["nix" "lua" "typescript" "tsx" "json" "bash"];
          };
        };

        # Auto-completion
        cmp = {
          enable = true;
        };

        # Fuzzy finder with file browser
        telescope = {
          enable = true;
          extensions = {
            fzf-native.enable = true;
            ui-select.enable = true;
          };
          settings = {
            defaults = {
              prompt_prefix = " ";
              selection_caret = " ";
              file_ignore_patterns = [
                "^.git/"
                "node_modules"
                ".devenv"
              ];
              layout_config = {
                horizontal = {
                  prompt_position = "top";
                };
              };
              sorting_strategy = "ascending";
            };
          };
        };

        web-devicons.enable = true;

        # Git integration
        gitsigns = {
          enable = true;
          settings = {
            current_line_blame = false; # Disable for performance
            update_debounce = 200; # Increase debounce for remote
          };
        };

        # File explorer with icons
        neo-tree = {
          enable = true;
          settings = {
            close_if_last_window = true;
            filesystem.filtered_items.hide_gitignored = true;
            git_status_async = true;
            window = {
              width = 35;
            };
          };
        };

        # Bufferline
        bufferline = {
          enable = true;
          settings.options = {
            diagnostics = "nvim_lsp";
            separator_style = "slant";
            offsets = [
              {
                filetype = "neo-tree";
                text = "File Explorer";
                separator = true;
              }
            ];
          };
        };

        # Beautiful status line
        lualine = {
          enable = true;
          settings.options = {
            theme = "catppuccin";
            globalstatus = true;
          };
        };

        # Indent guides (simplified for performance)
        indent-blankline = {
          enable = true;
          settings = {
            scope.enabled = false; # Disable for better performance over SSH
          };
        };

        # Auto-pairs
        nvim-autopairs.enable = true;

        # Comment toggle
        comment.enable = true;

        # Which-key for key discovery
        which-key = {
          enable = true;
          settings.spec = [
            {
              __unkeyed-1 = "<leader>f";
              group = "file";
            }
            {
              __unkeyed-1 = "<leader>b";
              group = "buffer";
            }
            {
              __unkeyed-1 = "<leader>w";
              group = "window";
            }
            {
              __unkeyed-1 = "<leader>s";
              group = "search";
            }
            {
              __unkeyed-1 = "<leader>o";
              group = "open";
            }
            {
              __unkeyed-1 = "<leader>g";
              group = "git";
            }
            {
              __unkeyed-1 = "<leader>a";
              group = "ai";
            }
            {
              __unkeyed-1 = "<leader>d";
              group = "diag";
            }
          ];
        };

        #copilot-lsp.enable = true;
        # Sidekick - AI sidekick
        sidekick = {
          enable = true;
          settings = {
            nes = {
              debounce = 150;
              trigger.events = ["InsertLeave" "TextChanged"];
              clear.events = ["TextChangedI" "TextChanged" "BufWritePre" "InsertEnter"];
            };
            cli = {
              mux = {
                backend = "zellij";
                enabled = true;
              };
              # Keep npx -y so each invocation pulls the latest CLI version
              tools = {
                claude = {
                  cmd = ["npx" "-y" "@anthropic-ai/claude-code"];
                  url = "https://github.com/anthropics/claude-code";
                };
                copilot = {
                  cmd = ["npx" "-y" "@github/copilot"];
                  url = "https://github.com/github/copilot-cli";
                };
                codex = {
                  cmd = ["npx" "-y" "@openai/codex"];
                  url = "https://github.com/openai/codex";
                };
                gemini = {
                  cmd = ["npx" "-y" "@google/gemini-cli"];
                  url = "https://github.com/google-gemini/gemini-cli";
                };
              };
            };
          };
        };
      };

      # Beautiful color scheme
      colorschemes.catppuccin = {
        enable = true;
        settings = {
          flavour = "mocha";
          # Performance optimizations for remote
          term_colors = false; # Don't set terminal colors
          dim_inactive.enabled = false; # Disable dimming
        };
      };

      globals.mapleader = " ";

      keymaps = [
        {
          mode = ["n"];
          key = "<Tab>";
          action = inputs.nixvim.lib.nixvim.mkRaw ''
            function()
              if not require("sidekick").nes_jump_or_apply() then
                return "<Tab>"
              end
            end
          '';
          options = {
            desc = "Goto/Apply Next Edit Suggestion";
            expr = true;
          };
        }
        {
          mode = ["n" "t" "i" "x"];
          key = "<C-\\>";
          action = "<cmd>lua require('sidekick.cli').toggle()<CR>";
          options.desc = "Sidekick Toggle";
        }
        {
          mode = ["n" "t" "i" "x"];
          key = "<C-.>";
          action = "<cmd>lua require('sidekick.cli').toggle()<CR>";
          options.desc = "Sidekick Toggle";
        }
        {
          mode = ["n"];
          key = "<leader>aa";
          action = "<cmd>lua require('sidekick.cli').toggle()<CR>";
          options.desc = "Sidekick Toggle CLI";
        }
        {
          mode = ["n"];
          key = "<leader>as";
          action = "<cmd>lua require('sidekick.cli').select()<CR>";
          options.desc = "Select CLI";
        }
        {
          mode = ["n"];
          key = "<leader>ad";
          action = "<cmd>lua require('sidekick.cli').close()<CR>";
          options.desc = "Detach a CLI Session";
        }
        {
          mode = ["x" "n"];
          key = "<leader>at";
          action = "<cmd>lua require('sidekick.cli').send({ msg = \"{this}\" })<CR>";
          options.desc = "Send This";
        }
        {
          mode = ["n"];
          key = "<leader>af";
          action = "<cmd>lua require('sidekick.cli').send({ msg = \"{file}\" })<CR>";
          options.desc = "Send File";
        }
        {
          mode = ["x"];
          key = "<leader>av";
          action = "<cmd>lua require('sidekick.cli').send({ msg = \"{selection}\" })<CR>";
          options.desc = "Send Visual Selection";
        }
        {
          mode = ["n" "x"];
          key = "<leader>ap";
          action = "<cmd>lua require('sidekick.cli').prompt()<CR>";
          options.desc = "Sidekick Select Prompt";
        }
        {
          mode = ["n"];
          key = "<leader>ac";
          action = "<cmd>lua require('sidekick.cli').toggle({ name = \"copilot\", focus = true })<CR>";
          options.desc = "Sidekick Toggle Copilot";
        }
        {
          mode = ["n"];
          key = "<leader>ff";
          action = "<cmd>Telescope find_files<CR>";
          options.desc = "Telescope Find Files";
        }
        {
          mode = ["n"];
          key = "<leader>fg";
          action = "<cmd>Telescope live_grep<CR>";
          options.desc = "Telescope Live Grep";
        }
        {
          mode = ["n"];
          key = "<leader>fb";
          action = "<cmd>Telescope buffers<CR>";
          options.desc = "Telescope Buffers";
        }
        {
          mode = ["n"];
          key = "<leader>e";
          action = "<cmd>Neotree toggle<CR>";
          options.desc = "Toggle Neo-tree";
        }
        {
          mode = ["n"];
          key = "]h";
          action = "<cmd>Gitsigns next_hunk<CR>";
          options.desc = "Next Git Hunk";
        }
        {
          mode = ["n"];
          key = "[h";
          action = "<cmd>Gitsigns prev_hunk<CR>";
          options.desc = "Previous Git Hunk";
        }
        {
          mode = ["n"];
          key = "<leader>hp";
          action = "<cmd>Gitsigns preview_hunk<CR>";
          options.desc = "Preview Git Hunk";
        }
        {
          mode = ["n"];
          key = "<leader>hs";
          action = "<cmd>Gitsigns stage_hunk<CR>";
          options.desc = "Stage Git Hunk";
        }
        {
          mode = ["n"];
          key = "<leader>hr";
          action = "<cmd>Gitsigns reset_hunk<CR>";
          options.desc = "Reset Git Hunk";
        }
        {
          mode = ["n"];
          key = "<leader>bn";
          action = "<cmd>BufferLineCycleNext<CR>";
          options.desc = "Next Buffer";
        }
        {
          mode = ["n"];
          key = "<leader>bp";
          action = "<cmd>BufferLineCyclePrev<CR>";
          options.desc = "Previous Buffer";
        }
        {
          mode = ["n"];
          key = "<leader>bd";
          action = "<cmd>bdelete<CR>";
          options.desc = "Close Buffer";
        }
        {
          mode = ["n"];
          key = "<leader>ld";
          action = "<cmd>lua vim.lsp.buf.definition()<CR>";
          options.desc = "LSP Definition";
        }
        {
          mode = ["n"];
          key = "<leader>lr";
          action = "<cmd>lua vim.lsp.buf.references()<CR>";
          options.desc = "LSP References";
        }
        {
          mode = ["n"];
          key = "<leader>la";
          action = "<cmd>lua vim.lsp.buf.code_action()<CR>";
          options.desc = "LSP Code Action";
        }
        {
          mode = ["n"];
          key = "<leader>ln";
          action = "<cmd>lua vim.lsp.buf.rename()<CR>";
          options.desc = "LSP Rename";
        }
        {
          mode = ["n"];
          key = "<leader>lk";
          action = "<cmd>lua vim.lsp.buf.hover()<CR>";
          options.desc = "LSP Hover";
        }
        {
          mode = ["n"];
          key = "<leader>lf";
          action = "<cmd>lua vim.lsp.buf.format()<CR>";
          options.desc = "LSP Format";
        }
        {
          mode = ["n"];
          key = "<leader>dd";
          action = "<cmd>lua vim.diagnostic.open_float()<CR>";
          options.desc = "Show Diagnostics";
        }
        {
          mode = ["n"];
          key = "<leader>dn";
          action = "<cmd>lua vim.diagnostic.goto_next()<CR>";
          options.desc = "Next Diagnostic";
        }
        {
          mode = ["n"];
          key = "<leader>dp";
          action = "<cmd>lua vim.diagnostic.goto_prev()<CR>";
          options.desc = "Previous Diagnostic";
        }
        {
          mode = ["i"];
          key = "<C-l>";
          action = "<cmd>lua require('cmp').complete()<CR>";
          options.desc = "Trigger completion";
        }
      ];
    };
  };
in {
  overlays = [
    (_final: prev: {
      inherit (inputs.devenv.packages.${prev.stdenv.hostPlatform.system}) devenv;
    })
  ];

  packages = [
    nvim # nixvim
    pkgs.alejandra
    pkgs.bashInteractive # for readline support in scripts
    pkgs.biome
    pkgs.deadnix
    pkgs.devenv
    pkgs.gh
    pkgs.git
    pkgs.lua-language-server
    pkgs.nixd
    pkgs.nodePackages.markdownlint-cli
    pkgs.nodePackages.bash-language-server
    pkgs.nodePackages.typescript
    pkgs.nodePackages.typescript-language-server
    pkgs.ripgrep
    pkgs.statix
    pkgs.vscode-langservers-extracted
    pkgs.zellij
  ];

  cachix.push = lib.mkIf (isDev && builtins.getEnv "CACHIX_AUTH_TOKEN" != "") "c0decafe";
  cachix.pull = ["c0decafe"];

  devcontainer.enable = false;
  starship.enable = isDev;

  env.PRE_COMMIT_HOME = lib.mkIf isDev "${config.devenv.runtime}/.cache/pre-commit";
  enterShell = lib.mkIf isDev ''
    export NIX_CONFIG="access-tokens = github.com=$GITHUB_TOKEN"
  '';

  languages = {
    nix.enable = true;
    javascript = {
      enable = true;
      package = pkgs.nodejs_22;
      corepack.enable = true;
      npm.enable = true;
    };
  };

  # Git hooks via cachix/git-hooks.nix
  git-hooks.hooks = {
    biome.enable = false;
    convco.enable = true;
    markdownlint.enable = true;
    alejandra = {
      enable = true;
      settings.check = true;
    };
    statix.enable = true;
    deadnix.enable = true;
  };

  # Developer convenience tasks
  tasks = {
    "fmt:nix" = {exec = "alejandra -q $(git ls-files \"*.nix\")";};
    "fmt:all" = {
      before = ["fmt:nix"];
      exec = "true";
    };

    "lint:nix" = {exec = "statix check && deadnix .";};
    "lint:all" = {
      before = ["lint:nix"];
      exec = "true";
    };
  };

  # Process manager and development processes
  process.managers.process-compose = {
    tui.enable = false;
    settings = {
      log_location = ".devenv/process-compose.log";
      log_level = "info";
    };
  };

  processes = lib.mkMerge [
    # Production process (always available)
    {
      serve = {
        exec = ''
          echo "[serve] Starting production server..."
          # Add your production start command here
          # Example: node dist/server.js
          # Example: npm run start
          sleep infinity
        '';
      };
    }
    # Development processes (only in dev mode)
    (lib.mkIf isDev {
      dev-server = {
        exec = ''
          # Example: `npm run dev -- --port 3000` for Webpack/Next/Vite dev servers
          # Example: `npm run start:dev` or `npm run dev-server` if those scripts already exist
          # Replace the examples above with the script that matches your project’s CLI.
          sleep infinity
        '';
      };

      # TypeScript/Biome watcher for continuous checking
      watcher = {
        exec = ''
          echo "[watcher] Starting file watcher for linting..."
          # Add your watch command here
          # Example: npm run watch
          # Example: biome check --watch .
          sleep infinity
        '';
      };
    })
  ];

  containers.latest = {
    inherit name version;
    startupCommand = config.processes.serve.exec;
  };
}
