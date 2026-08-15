-- =============================================================
--  config/autocmds.lua  |  Autocomandos del editor
-- =============================================================

local augroup  = vim.api.nvim_create_augroup
local autocmd  = vim.api.nvim_create_autocmd

-- Resaltar texto al copiar (yank)
autocmd("TextYankPost", {
  group    = augroup("highlight_yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
  end,
})

-- Igualar splits al redimensionar ventana
autocmd("VimResized", {
  group    = augroup("resize_splits", { clear = true }),
  callback = function()
    local tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. tab)
  end,
})

-- Python: 4 espacios (PEP 8)
autocmd("FileType", {
  group   = augroup("python_indent", { clear = true }),
  pattern = "python",
  callback = function()
    vim.opt_local.tabstop    = 4
    vim.opt_local.shiftwidth = 4
  end,
})

-- C# / .NET: 4 espacios (convención Microsoft)
autocmd("FileType", {
  group   = augroup("csharp_indent", { clear = true }),
  pattern = { "cs" },
  callback = function()
    vim.opt_local.tabstop    = 4
    vim.opt_local.shiftwidth = 4
  end,
})

-- Cerrar ventanas auxiliares con 'q'
autocmd("FileType", {
  group   = augroup("close_with_q", { clear = true }),
  pattern = { "help", "lspinfo", "man", "qf", "checkhealth", "notify" },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})

-- Restaurar posición del cursor al reabrir archivo
autocmd("BufReadPost", {
  group    = augroup("restore_cursor", { clear = true }),
  callback = function(event)
    local mark = vim.api.nvim_buf_get_mark(event.buf, '"')
    local lcount = vim.api.nvim_buf_line_count(event.buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})
