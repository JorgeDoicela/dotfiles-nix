-- =============================================================
--  config/options.lua  |  Opciones del editor
--  Estándar: PEP8 para Python, 2 espacios para JS/TS/Lua
-- =============================================================

-- Filtro de avisos falso-positivos en Neovim 0.10
local _notify = vim.notify
vim.notify = function(msg, level, opts)
  if type(msg) == "string" and (msg:find("deprecated") or msg:find("lspconfig")) then return end
  _notify(msg, level, opts)
end

local opt = vim.opt

-- UI
opt.number         = true
opt.relativenumber = true
opt.cursorline     = true
opt.signcolumn     = "yes"        -- Columna fija para LSP signs (evita layout shift)
opt.termguicolors  = true
opt.scrolloff      = 8            -- Margen vertical al scroll
opt.sidescrolloff  = 8
opt.wrap           = false
opt.list           = true
opt.listchars      = { tab = "» ", trail = "·", nbsp = "␣" }

-- Edición
opt.expandtab      = true         -- Espacios en lugar de tabs (estándar industria)
opt.tabstop        = 2            -- 2 espacios: JS/TS/Lua/YAML
opt.shiftwidth     = 2
opt.smartindent    = true
opt.clipboard      = "unnamedplus" -- Compartir portapapeles con el sistema
opt.undofile       = true         -- Historial persistente entre sesiones
opt.updatetime     = 100

-- Búsqueda
opt.ignorecase     = true         -- Case-insensitive por defecto
opt.smartcase      = true         -- Pero sensible si escribes mayúsculas
opt.hlsearch       = true

-- Ventanas
opt.splitbelow     = true         -- Splits horizontales abajo
opt.splitright     = true         -- Splits verticales a la derecha

-- Performance
opt.timeoutlen     = 300          -- Tiempo para which-key
opt.updatetime     = 100          -- Diagnósticos más rápidos
