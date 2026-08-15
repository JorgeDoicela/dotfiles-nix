-- =============================================================
--  plugins/treesitter.lua  |  Resaltado y estructura de código
--  Stack completo: Web + Python + .NET + DevSecOps + DB
-- =============================================================
return {
  {
    "nvim-treesitter/nvim-treesitter",
    build  = ":TSUpdate",
    event  = { "BufReadPost", "BufNewFile" },
    config = function()
      local ok, configs = pcall(require, "nvim-treesitter.configs")
      if not ok then return end

      configs.setup({
        ensure_installed = {
          -- JavaScript / TypeScript ecosystem
          "javascript", "typescript", "tsx",
          "html", "css", "json", "json5", "graphql",

          -- Python
          "python",

          -- C# / .NET
          "c_sharp",

          -- DevSecOps / Infrastructure
          "bash", "dockerfile", "yaml", "toml", "hcl",
          "regex",                  -- Para análisis de patrones regex

          -- Base de datos
          "sql",

          -- Config de Neovim
          "lua", "vim", "vimdoc",

          -- Markup / Docs
          "markdown", "markdown_inline",

          -- Git
          "gitignore", "gitcommit", "diff",
        },

        -- Resaltado de sintaxis (reemplaza al regex de Vim)
        highlight = {
          enable = true,
          disable = function(_, buf)
            -- Desactivar en archivos muy grandes (>100 KB) por rendimiento
            local max_filesize = 100 * 1024
            local ok2, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
            if ok2 and stats and stats.size > max_filesize then return true end
          end,
        },

        -- Indentación basada en treesitter
        indent = { enable = true },

        -- Selección incremental con Ctrl+Space
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection    = "<C-space>",
            node_incremental  = "<C-space>",
            scope_incremental = false,
            node_decremental  = "<bs>",
          },
        },
      })
    end,
  },
}
