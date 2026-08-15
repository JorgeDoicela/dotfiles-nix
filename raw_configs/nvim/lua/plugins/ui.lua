-- =============================================================
--  plugins/ui.lua  |  Estética y UI global
-- =============================================================
return {

  -- ── Colorscheme ─────────────────────────────────────────────
  {
    "folke/tokyonight.nvim",
    lazy     = false,
    priority = 1000,
    config = function()
      require("tokyonight").setup({
        style           = "moon",
        transparent     = false,
        terminal_colors = true,
        styles = {
          comments = { italic = true },
          keywords = { italic = true },
        },
      })
      vim.cmd("colorscheme tokyonight-moon")
    end,
  },

  -- ── Status line ─────────────────────────────────────────────
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = {
      options = {
        theme           = "tokyonight",
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
