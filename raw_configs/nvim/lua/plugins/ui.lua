-- =============================================================
--  plugins/ui.lua  |  Estética y UI global
-- =============================================================
return {

  -- ── Colorscheme Apple macOS / Xcode Dark ───────────────────
  {
    "projekt0n/github-nvim-theme",
    lazy     = false,
    priority = 1000,
    config = function()
      require("github-theme").setup({
        options = {
          styles = {
            comments = "italic",
            keywords = "bold",
            types = "italic,bold",
          },
        },
      })
      vim.cmd("colorscheme github_dark_default")
    end,
  },

  -- ── Status line ─────────────────────────────────────────────
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = {
      options = {
        theme           = "auto",
        globalstatus    = true,
        disabled_filetypes = { statusline = { "dashboard", "lazy", "alpha" } },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = { { "filename", path = 1 } },  -- Ruta relativa
        lualine_x = { "encoding", "fileformat", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    },
  },

  -- ── Buffer tabs ─────────────────────────────────────────────
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    keys = {
      { "<S-h>",      "<cmd>BufferLineCyclePrev<cr>", desc = "Buffer anterior" },
      { "<S-l>",      "<cmd>BufferLineCycleNext<cr>", desc = "Buffer siguiente" },
      { "<leader>bp", "<cmd>BufferLineTogglePin<cr>",  desc = "Pin buffer" },
    },
    opts = {
      options = {
        diagnostics        = "nvim_lsp",
        always_show_bufferline = false,
        offsets = {
          { filetype = "dbui",     text = "󰆼 Database",     highlight = "Directory" },
          { filetype = "NvimTree", text = "󰉋 Files",         highlight = "Directory" },
        },
      },
    },
  },

  -- ── Indent guides ────────────────────────────────────────────
  {
    "lukas-reineke/indent-blankline.nvim",
    event = "BufReadPost",
    main  = "ibl",
    opts = {
      indent = { char = "│" },
      scope  = { enabled = true },
    },
  },

  -- ── Icons ────────────────────────────────────────────────────
  { "nvim-tree/nvim-web-devicons", lazy = true },
}
