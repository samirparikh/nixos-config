vim.g.mapleader = " "
vim.g.maplocalleader = " "

local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true
opt.wrap = false
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true
opt.termguicolors = true
opt.signcolumn = "yes"
opt.scrolloff = 8
opt.updatetime = 250
opt.mouse = "a"
opt.clipboard = "unnamedplus"

require("catppuccin").setup({
  flavour = "mocha",
  integrations = {
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

require("nvim-treesitter.configs").setup({
  highlight = { enable = true },
  indent = { enable = false },
})

require("lualine").setup({
  options = {
    theme = "catppuccin",
    globalstatus = true,
    section_separators = "",
    component_separators = "|",
  },
})

require("lensline").setup({
  profiles = {
    {
      name = "default",
      providers = {
        {
          name = "usages",
          enabled = true,
          include = { "refs" },
          breakdown = false,
          show_zero = true,
        },
      },
      style = {
        placement = "above",
        prefix = "",
        separator = " • ",
        highlight = "Comment",
        render = "all",
        use_nerdfont = true,
      },
    },
  },
  debounce_ms = 300,
  silence_lsp = true,
})

if vim.g.nix_fsautocomplete_bin then
  vim.g["fsharp#fsautocomplete_command"] = { vim.g.nix_fsautocomplete_bin }
end
vim.g["fsharp#backend"] = "nvim"
vim.g["fsharp#lsp_recommended_colorscheme"] = 0
vim.g["fsharp#automatic_workspace_init"] = 1
vim.g["fsharp#automatic_reload_workspace"] = 1
vim.g["fsharp#linter"] = 1
vim.g["fsharp#unused_opens_analyzer"] = 1
vim.g["fsharp#unused_declarations_analyzer"] = 1

vim.diagnostic.config({
  virtual_text = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = "rounded",
    source = true,
  },
})

local codelens_group = vim.api.nvim_create_augroup("UserCodeLens", { clear = true })

local function buffer_supports_codelens(bufnr)
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
    if client.supports_method("textDocument/codeLens") then
      return true
    end
  end
  return false
end

local function refresh_codelens(bufnr)
  if buffer_supports_codelens(bufnr) then
    vim.lsp.codelens.refresh({ bufnr = bufnr })
  end
end

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
  callback = function(ev)
    local bufnr = ev.buf
    local opts = { buffer = bufnr, silent = true }

    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "<leader>f", function()
      vim.lsp.buf.format({ async = true })
    end, opts)
    vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
    vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
    vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)

    vim.keymap.set("n", "<leader>cl", function()
      vim.lsp.codelens.run()
    end, vim.tbl_extend("force", opts, { desc = "Run CodeLens" }))

    if buffer_supports_codelens(bufnr) then
      vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
        group = codelens_group,
        buffer = bufnr,
        callback = function(args)
          refresh_codelens(args.buf)
        end,
      })

      refresh_codelens(bufnr)
    end
  end,
})

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })
vim.keymap.set("n", "<leader>w", "<cmd>w<cr>", { desc = "Save file" })
vim.keymap.set("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit" })
