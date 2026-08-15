-- =============================================================
--  plugins/navigation.lua  |  Exploración de archivos
-- =============================================================
return {

  -- ── fzf-lua: fuzzy finder ────────────────────────────────────
  {
    "ibhagwan/fzf-lua",
    event = "VeryLazy",
    config = function()
      require("fzf-lua").setup({
        winopts = {
          border  = "rounded",
          preview = { layout = "vertical", vertical = "down:55%" },
        },
      })
    end,
    keys = {
      { "<leader>f",  "<cmd>FzfLua files<cr>",              desc = "Buscar archivos" },
      { "<leader>sg", "<cmd>FzfLua live_grep<cr>",          desc = "Buscar en código (grep)" },
      { "<leader>sb", "<cmd>FzfLua buffers<cr>",            desc = "Buscar buffers" },
      { "<leader>sr", "<cmd>FzfLua oldfiles<cr>",           desc = "Archivos recientes" },
      { "<leader>sc", "<cmd>FzfLua commands<cr>",           desc = "Comandos" },
      { "<leader>sd", "<cmd>FzfLua diagnostics_document<cr>", desc = "Diagnósticos doc" },
      { "<leader>ss", "<cmd>FzfLua lsp_document_symbols<cr>", desc = "Símbolos LSP" },
      { "<leader>sS", "<cmd>FzfLua lsp_workspace_symbols<cr>", desc = "Símbolos workspace" },
    },
  },

  -- ── Yazi: file manager TUI ───────────────────────────────────
  {
    "mikavilpas/yazi.nvim",
    event = "VeryLazy",
    keys = {
      { "<leader>y", "<cmd>Yazi<cr>",     desc = "Abrir Yazi (archivo actual)" },
      { "<leader>Y", "<cmd>Yazi cwd<cr>", desc = "Abrir Yazi (directorio)" },
    },
  },
}
