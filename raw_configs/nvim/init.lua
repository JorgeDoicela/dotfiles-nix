-- =============================================================
--  init.lua  |  Entry point (Jorge Doicela)
--  Responsabilidad única: cargar módulos de config y lazy
--  No debe contener lógica — solo require()
-- =============================================================

-- Leader debe definirse ANTES de cargar lazy
vim.g.mapleader      = " "
vim.g.maplocalleader = "\\"

require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.lazy")
