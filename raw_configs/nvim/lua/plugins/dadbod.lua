-- =============================================================
--  plugins/dadbod.lua  |  Cliente de Base de Datos
--  DevSecOps: credenciales en $DB_UI_CONNECTIONS (~/.config/zsh/conf.d/secrets.zsh)
--  Requiere: default-mysql-client (apt install default-mysql-client)
-- =============================================================
return {

  -- Motor (wrapper del cliente MySQL del sistema)
  {
    "tpope/vim-dadbod",
    lazy = true,
  },

  -- UI tipo explorador de árbol
  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = {
      { "tpope/vim-dadbod",                     lazy = true },
      { "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true },
    },
    cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
    keys = {
      { "<leader>db", "<cmd>DBUIToggle<cr>",       desc = "Toggle DB Explorer" },
      { "<leader>da", "<cmd>DBUIAddConnection<cr>", desc = "Añadir conexión DB" },
      { "<leader>df", "<cmd>DBUIFindBuffer<cr>",    desc = "Buscar buffer SQL" },
    },
    init = function()
      -- Estética con Nerd Fonts
      vim.g.db_ui_use_nerd_fonts             = 1
      vim.g.db_ui_show_database_navigation   = 1
      vim.g.db_ui_winwidth                   = 35

      -- Queries guardadas en HDD (stdpath data = ~/.local/share/nvim)
      -- NUNCA dentro del repo de dotfiles → cero riesgo de subir credenciales
      vim.g.db_ui_save_location = vim.fn.stdpath("data") .. "/db_ui_queries"

      -- Conexiones desde variable de entorno (práctica DevSecOps)
      -- Definida en ~/.config/zsh/conf.d/secrets.zsh
      if os.getenv("DB_UI_CONNECTIONS") then
        vim.g.db_ui_env_variable_connections = "DB_UI_CONNECTIONS"
      end
    end,
    config = function()
      -- Autocompletado SQL con blink.cmp
      vim.api.nvim_create_autocmd("FileType", {
        pattern  = { "sql", "mysql", "plsql" },
        callback = function()
          local ok, blink = pcall(require, "blink.cmp")
          if ok and blink.add_source then
            blink.add_source("dadbod", {
              module = "vim_dadbod_completion.blink",
              name   = "Dadbod",
            })
          end
        end,
      })
    end,
  },
}
