-- =============================================================
--  plugins/editor.lua  |  Herramientas de edición
-- =============================================================
return {

  -- ── Which-key: guía de atajos ────────────────────────────────
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      win = { border = "rounded" },
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
      -- Registrar grupos de leader para mejor navegación
      wk.add({
        { "<leader>b",  group = "Buffers" },
        { "<leader>c",  group = "Código / Format" },
        { "<leader>d",  group = "Base de Datos" },
        { "<leader>g",  group = "Git" },
        { "<leader>s",  group = "Buscar" },
        { "<leader>t",  group = "Test / Terminal" },
        { "<leader>x",  group = "Diagnósticos" },
      })
    end,
  },

  -- ── Auto-pairs ──────────────────────────────────────────────
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts  = { check_ts = true },  -- Treesitter-aware (no cierra en strings)
  },

  -- ── Surround: cs"' ds( ysiw" ────────────────────────────────
  {
    "kylechui/nvim-surround",
    event  = "VeryLazy",
    config = true,
  },

  -- ── Comentarios: gcc / gc (visual) ──────────────────────────
  {
    "numToStr/Comment.nvim",
    event  = "VeryLazy",
    config = true,
  },

  -- ── Diagnósticos: lista organizada ──────────────────────────
  {
    "folke/trouble.nvim",
    cmd  = { "Trouble" },
    opts = { use_diagnostic_signs = true },
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>",              desc = "Diagnósticos (Trouble)" },
      { "<leader>xb", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Diagnósticos buffer" },
      { "<leader>xl", "<cmd>Trouble loclist toggle<cr>",                  desc = "Lista de location" },
      { "<leader>xq", "<cmd>Trouble qflist toggle<cr>",                   desc = "Quickfix list" },
    },
  },

  -- ── TODO/FIXME/HACK comments ────────────────────────────────
  {
    "folke/todo-comments.nvim",
    event  = "BufReadPost",
    config = true,
    keys = {
      { "<leader>xt", "<cmd>TodoTrouble<cr>",     desc = "TODOs (Trouble)" },
      { "<leader>st", "<cmd>TodoFzfLua<cr>",      desc = "Buscar TODOs" },
      { "]t",         function() require("todo-comments").jump_next() end, desc = "TODO siguiente" },
      { "[t",         function() require("todo-comments").jump_prev() end, desc = "TODO anterior" },
    },
  },

  -- ── ToggleTerm: Terminal flotante/integrada ──────────────────
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    opts = {
      size = 15,
      open_mapping = [[<C-\>]], -- Ctrl + \ abre/cierra la terminal desde cualquier modo
      hide_numbers = true,
      shade_terminals = true,
      start_in_insert = true,
      insert_mappings = true,
      terminal_mappings = true,
      persist_size = true,
      direction = "float", -- Flotante por defecto
      close_on_exit = true,
      float_opts = {
        border = "rounded",
        winblend = 3,
      },
    },
    keys = {
      { "<leader>tt", "<cmd>ToggleTerm direction=float<cr>", desc = "Terminal: Flotante" },
      { "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>", desc = "Terminal: Horizontal" },
      { "<leader>tv", "<cmd>ToggleTerm direction=vertical size=60<cr>", desc = "Terminal: Vertical" },
    },
  },

  -- ── Undotree: Historial de cambios en árbol ──────────────────
  {
    "mbbill/undotree",
    keys = {
      { "<leader>u", "<cmd>UndotreeToggle<cr>", desc = "Historial deshacer (Undotree)" },
    },
    config = function()
      -- Ajustar visualización estética de undotree
      vim.g.undotree_WindowLayout = 2
      vim.g.undotree_ShortIndicators = 1
    end,
  },
}
