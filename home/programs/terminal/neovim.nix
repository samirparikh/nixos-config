{ config, pkgs, inputs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    # Extra packages available to neovim (LSP servers, formatters, etc.)
    extraPackages = with pkgs; [
      # C# / .NET
      omnisharp-roslyn
      netcoredbg
      csharpier          # C# formatter

      # General utilities
      ripgrep            # for telescope
      fd                 # for telescope
      tree-sitter        # for treesitter
      nodejs_22          # required for Copilot
    ];

    plugins = with pkgs.vimPlugins; [
      # ============================================================
      # Core plugins
      # ============================================================
      plenary-nvim       # Required by many plugins

      # ============================================================
      # UI / Theme (Catppuccin to match your system)
      # ============================================================
      {
        plugin = catppuccin-nvim;
        type = "lua";
        config = ''
          require("catppuccin").setup({
            flavour = "mocha",
            integrations = {
              cmp = true,
              gitsigns = true,
              nvimtree = true,
              treesitter = true,
              telescope = { enabled = true },
              native_lsp = {
                enabled = true,
                underlines = {
                  errors = { "undercurl" },
                  hints = { "undercurl" },
                  warnings = { "undercurl" },
                  information = { "undercurl" },
                },
              },
            },
          })
          vim.cmd.colorscheme("catppuccin")
        '';
      }

      # Status line
      {
        plugin = lualine-nvim;
        type = "lua";
        config = ''
          require("lualine").setup({
            options = {
              theme = "catppuccin",
              component_separators = { left = "", right = "" },
              section_separators = { left = "", right = "" },
            },
          })
        '';
      }

      # ============================================================
      # File explorer
      # ============================================================
      nvim-web-devicons
      {
        plugin = nvim-tree-lua;
        type = "lua";
        config = ''
          require("nvim-tree").setup({
            view = { width = 35 },
            filters = { dotfiles = false },
          })
          vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<cr>", { desc = "Toggle file explorer" })
        '';
      }

      # ============================================================
      # Treesitter for syntax highlighting
      # ============================================================
      {
        plugin = nvim-treesitter.withAllGrammars;
        type = "lua";
        config = ''
          require("nvim-treesitter.configs").setup({
            highlight = { enable = true },
            indent = { enable = true },
          })
        '';
      }

      # ============================================================
      # Telescope (fuzzy finder)
      # ============================================================
      telescope-fzf-native-nvim
      {
        plugin = telescope-nvim;
        type = "lua";
        config = ''
          local telescope = require("telescope")
          telescope.setup({
            defaults = {
              file_ignore_patterns = { "node_modules", ".git/", "bin/", "obj/" },
            },
            extensions = {
              fzf = {
                fuzzy = true,
                override_generic_sorter = true,
                override_file_sorter = true,
              },
            },
          })
          telescope.load_extension("fzf")

          local builtin = require("telescope.builtin")
          vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
          vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
          vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find buffers" })
          vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help tags" })
          vim.keymap.set("n", "<leader>fs", builtin.lsp_document_symbols, { desc = "Document symbols" })
        '';
      }

      # ============================================================
      # LSP Configuration
      # ============================================================
      {
        plugin = nvim-lspconfig;
        type = "lua";
        config = ''
          local lspconfig = require("lspconfig")

          -- Shared on_attach function for keybindings
          local on_attach = function(client, bufnr)
            local opts = { buffer = bufnr, silent = true }

            vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
            vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
            vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
            vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
            vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
            vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
            vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
            vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
            vim.keymap.set("n", "<leader>f", function() vim.lsp.buf.format({ async = true }) end, opts)
            vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
            vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
            vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)
          end

          -- LSP capabilities (enhanced by nvim-cmp)
          local capabilities = require("cmp_nvim_lsp").default_capabilities()

          -- ========================================
          -- Omnisharp (C# LSP)
          -- ========================================
          lspconfig.omnisharp.setup({
            cmd = { "${pkgs.omnisharp-roslyn}/bin/OmniSharp" },
            on_attach = on_attach,
            capabilities = capabilities,
            settings = {
              FormattingOptions = {
                EnableEditorConfigSupport = true,
                OrganizeImports = true,
              },
              RoslynExtensionsOptions = {
                EnableAnalyzersSupport = true,
                EnableImportCompletion = true,
              },
            },
            -- Enable semantic tokens for better highlighting
            enable_roslyn_analyzers = true,
            organize_imports_on_format = true,
            enable_import_completion = true,
          })
        '';
      }

      # ============================================================
      # Autocompletion with nvim-cmp
      # ============================================================
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      cmp-cmdline
      luasnip
      cmp_luasnip
      friendly-snippets
      lspkind-nvim

      {
        plugin = nvim-cmp;
        type = "lua";
        config = ''
          local cmp = require("cmp")
          local luasnip = require("luasnip")
          local lspkind = require("lspkind")

          -- Load friendly-snippets
          require("luasnip.loaders.from_vscode").lazy_load()

          cmp.setup({
            snippet = {
              expand = function(args)
                luasnip.lsp_expand(args.body)
              end,
            },
            mapping = cmp.mapping.preset.insert({
              ["<C-b>"] = cmp.mapping.scroll_docs(-4),
              ["<C-f>"] = cmp.mapping.scroll_docs(4),
              ["<C-Space>"] = cmp.mapping.complete(),
              ["<C-e>"] = cmp.mapping.abort(),
              ["<CR>"] = cmp.mapping.confirm({ select = true }),
              ["<Tab>"] = cmp.mapping(function(fallback)
                if cmp.visible() then
                  cmp.select_next_item()
                elseif luasnip.expand_or_jumpable() then
                  luasnip.expand_or_jump()
                else
                  fallback()
                end
              end, { "i", "s" }),
              ["<S-Tab>"] = cmp.mapping(function(fallback)
                if cmp.visible() then
                  cmp.select_prev_item()
                elseif luasnip.jumpable(-1) then
                  luasnip.jump(-1)
                else
                  fallback()
                end
              end, { "i", "s" }),
            }),
            sources = cmp.config.sources({
              { name = "copilot", group_index = 2 },  -- Copilot suggestions
              { name = "nvim_lsp", group_index = 2 },
              { name = "luasnip", group_index = 2 },
              { name = "path", group_index = 2 },
            }, {
              { name = "buffer" },
            }),
            formatting = {
              format = lspkind.cmp_format({
                mode = "symbol_text",
                maxwidth = 50,
                ellipsis_char = "...",
                symbol_map = { Copilot = "" },
              }),
            },
            window = {
              completion = cmp.config.window.bordered(),
              documentation = cmp.config.window.bordered(),
            },
          })

          -- Command line completion
          cmp.setup.cmdline(":", {
            mapping = cmp.mapping.preset.cmdline(),
            sources = cmp.config.sources({
              { name = "path" },
            }, {
              { name = "cmdline" },
            }),
          })

          -- Search completion
          cmp.setup.cmdline("/", {
            mapping = cmp.mapping.preset.cmdline(),
            sources = { { name = "buffer" } },
          })
        '';
      }

      # ============================================================
      # GitHub Copilot (AI completion)
      # ============================================================
      {
        plugin = copilot-lua;
        type = "lua";
        config = ''
          require("copilot").setup({
            suggestion = {
              enabled = true,
              auto_trigger = true,
              keymap = {
                accept = "<M-l>",           -- Alt+l to accept
                accept_word = "<M-k>",      -- Alt+k to accept word
                accept_line = "<M-j>",      -- Alt+j to accept line
                next = "<M-]>",
                prev = "<M-[>",
                dismiss = "<C-]>",
              },
            },
            panel = {
              enabled = true,
              auto_refresh = true,
              keymap = {
                open = "<M-CR>",
              },
            },
            filetypes = {
              yaml = true,
              markdown = true,
              cs = true,                   -- C#
              ["*"] = true,                -- Enable for all filetypes
            },
          })
        '';
      }

      # Copilot integration with nvim-cmp
      {
        plugin = copilot-cmp;
        type = "lua";
        config = ''
          require("copilot_cmp").setup()
        '';
      }

      # ============================================================
      # Git integration
      # ============================================================
      {
        plugin = gitsigns-nvim;
        type = "lua";
        config = ''
          require("gitsigns").setup({
            signs = {
              add = { text = "│" },
              change = { text = "│" },
              delete = { text = "_" },
              topdelete = { text = "‾" },
              changedelete = { text = "~" },
            },
            on_attach = function(bufnr)
              local gs = package.loaded.gitsigns
              local opts = { buffer = bufnr }
              vim.keymap.set("n", "]c", function() gs.next_hunk() end, opts)
              vim.keymap.set("n", "[c", function() gs.prev_hunk() end, opts)
              vim.keymap.set("n", "<leader>hs", gs.stage_hunk, opts)
              vim.keymap.set("n", "<leader>hr", gs.reset_hunk, opts)
              vim.keymap.set("n", "<leader>hp", gs.preview_hunk, opts)
              vim.keymap.set("n", "<leader>hb", function() gs.blame_line({ full = true }) end, opts)
            end,
          })
        '';
      }

      # ============================================================
      # Quality of life plugins
      # ============================================================
      {
        plugin = comment-nvim;
        type = "lua";
        config = ''require("Comment").setup()'';
      }

      {
        plugin = nvim-autopairs;
        type = "lua";
        config = ''
          require("nvim-autopairs").setup({})
          -- Integration with nvim-cmp
          local cmp_autopairs = require("nvim-autopairs.completion.cmp")
          require("cmp").event:on("confirm_done", cmp_autopairs.on_confirm_done())
        '';
      }

      {
        plugin = which-key-nvim;
        type = "lua";
        config = ''
          require("which-key").setup({})
        '';
      }

      {
        plugin = indent-blankline-nvim;
        type = "lua";
        config = ''
          require("ibl").setup({
            indent = { char = "│" },
            scope = { enabled = true },
          })
        '';
      }

      # DAP (Debug Adapter Protocol) for debugging
      nvim-dap
      nvim-dap-ui
      {
        plugin = nvim-dap;
        type = "lua";
        config = ''
          local dap = require("dap")

          -- C# / .NET Core debugging with netcoredbg
          dap.adapters.coreclr = {
            type = "executable",
            command = "${pkgs.netcoredbg}/bin/netcoredbg",
            args = { "--interpreter=vscode" },
          }

          dap.configurations.cs = {
            {
              type = "coreclr",
              name = "Launch - netcoredbg",
              request = "launch",
              program = function()
                return vim.fn.input("Path to dll: ", vim.fn.getcwd() .. "/bin/Debug/", "file")
              end,
            },
          }

          -- DAP keybindings
          vim.keymap.set("n", "<F5>", function() dap.continue() end)
          vim.keymap.set("n", "<F10>", function() dap.step_over() end)
          vim.keymap.set("n", "<F11>", function() dap.step_into() end)
          vim.keymap.set("n", "<F12>", function() dap.step_out() end)
          vim.keymap.set("n", "<leader>b", function() dap.toggle_breakpoint() end)
          vim.keymap.set("n", "<leader>B", function() dap.set_breakpoint(vim.fn.input("Breakpoint condition: ")) end)
        '';
      }

      {
        plugin = nvim-dap-ui;
        type = "lua";
        config = ''
          local dap, dapui = require("dap"), require("dapui")
          dapui.setup()

          -- Automatically open/close DAP UI
          dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
          dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
          dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end

          vim.keymap.set("n", "<leader>du", function() dapui.toggle() end)
        '';
      }
    ];

    # Extra Lua configuration (general settings)
    extraLuaConfig = ''
      -- ============================================================
      -- General settings
      -- ============================================================
      vim.g.mapleader = " "
      vim.g.maplocalleader = " "

      local opt = vim.opt

      -- Line numbers
      opt.number = true
      opt.relativenumber = true

      -- Tabs & indentation
      opt.tabstop = 4
      opt.shiftwidth = 4
      opt.expandtab = true
      opt.autoindent = true
      opt.smartindent = true

      -- Line wrapping
      opt.wrap = false

      -- Search settings
      opt.ignorecase = true
      opt.smartcase = true
      opt.hlsearch = true
      opt.incsearch = true

      -- Appearance
      opt.termguicolors = true
      opt.signcolumn = "yes"
      opt.cursorline = true
      opt.scrolloff = 8
      opt.sidescrolloff = 8

      -- Behavior
      opt.splitright = true
      opt.splitbelow = true
      opt.mouse = "a"
      opt.clipboard = "unnamedplus"
      opt.updatetime = 250
      opt.timeoutlen = 300
      opt.undofile = true
      opt.swapfile = false
      opt.backup = false

      -- Completion
      opt.completeopt = "menu,menuone,noselect"

      -- ============================================================
      -- Keybindings
      -- ============================================================
      local keymap = vim.keymap.set

      -- Better window navigation
      keymap("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
      keymap("n", "<C-j>", "<C-w>j", { desc = "Move to lower window" })
      keymap("n", "<C-k>", "<C-w>k", { desc = "Move to upper window" })
      keymap("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

      -- Resize windows
      keymap("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
      keymap("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
      keymap("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
      keymap("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

      -- Buffer navigation
      keymap("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
      keymap("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
      keymap("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete buffer" })

      -- Clear search highlighting
      keymap("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })

      -- Better indenting in visual mode
      keymap("v", "<", "<gv", { desc = "Indent left" })
      keymap("v", ">", ">gv", { desc = "Indent right" })

      -- Move lines up/down
      keymap("v", "J", ":m '>+1<cr>gv=gv", { desc = "Move line down" })
      keymap("v", "K", ":m '<-2<cr>gv=gv", { desc = "Move line up" })

      -- Quick save
      keymap("n", "<leader>w", "<cmd>w<cr>", { desc = "Save file" })
      keymap("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit" })

      -- ============================================================
      -- Diagnostics configuration
      -- ============================================================
      vim.diagnostic.config({
        virtual_text = true,
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        float = {
          border = "rounded",
          source = "always",
        },
      })

      -- Diagnostic signs
      local signs = { Error = " ", Warn = " ", Hint = "󰌵 ", Info = " " }
      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
      end
    '';
  };
}
