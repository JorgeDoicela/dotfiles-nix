-- =============================================================
--  config/lazy.lua  |  Bootstrap e inicialización de lazy.nvim
-- =============================================================

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    { import = "plugins" }, -- Carga automática de lua/plugins/*.lua
  },
  defaults = {
    lazy    = true,         -- Todo lazy-loaded por defecto
    version = false,        -- Usar HEAD en lugar de versiones semver
  },
  checker = {
    enabled = true,         -- Verificar actualizaciones al iniciar
    notify  = false,        -- Sin spam de notificaciones
  },
  change_detection = {
    notify = false,         -- No notificar al cambiar config
  },
  performance = {
    rtp = {
      -- Desactivar plugins built-in no usados (mejora de startup)
      disabled_plugins = {
        "gzip", "tarPlugin", "tohtml",
        "tutor", "zipPlugin",
      },
    },
  },
})
