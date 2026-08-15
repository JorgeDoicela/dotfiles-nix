-- =============================================================
--  plugins/completion.lua  |  Autocompletado (blink.cmp)
--  blink.cmp usa Rust → significativamente más rápido que nvim-cmp
-- =============================================================
return {
  {
    "saghen/blink.cmp",
    version      = "*",
    event        = "InsertEnter",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      keymap = { preset = "default" },
      appearance = {
        use_nvim_cmp_as_default = false,
        nerd_font_variant       = "mono",
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer", "codecompanion" },
        providers = {
          codecompanion = {
            name = "CodeCompanion",
            module = "codecompanion.providers.completion.blink",
          },
        },
      },
      completion = {
        menu          = { border = "rounded" },
        documentation = { window = { border = "rounded" } },
      },
    },
  },
}
