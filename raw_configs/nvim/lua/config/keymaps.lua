-- =============================================================
--  config/keymaps.lua  |  Atajos globales (no dependientes de plugins)
--  Los keymaps específicos de plugins van en su archivo respectivo
--  usando el campo `keys` de lazy.nvim
-- =============================================================

local map = vim.keymap.set

-- ── Ventanas ──────────────────────────────────────────────────
map("n", "<C-h>", "<C-w>h",  { desc = "Ventana izquierda" })
map("n", "<C-j>", "<C-w>j",  { desc = "Ventana abajo" })
map("n", "<C-k>", "<C-w>k",  { desc = "Ventana arriba" })
map("n", "<C-l>", "<C-w>l",  { desc = "Ventana derecha" })

-- ── Buffers ───────────────────────────────────────────────────
map("n", "<S-h>",       "<cmd>bprevious<cr>",     { desc = "Buffer anterior" })
map("n", "<S-l>",       "<cmd>bnext<cr>",          { desc = "Buffer siguiente" })
map("n", "<leader>bd",  "<cmd>bdelete<cr>",        { desc = "Cerrar buffer" })

-- ── Edición ───────────────────────────────────────────────────
-- Mantener selección visual al indentar
map("v", "<",  "<gv", { desc = "Indentar izquierda" })
map("v", ">",  ">gv", { desc = "Indentar derecha" })

-- Mover líneas con Alt+j/k (igual que VS Code)
map("n", "<A-j>", "<cmd>m .+1<cr>==",    { desc = "Mover línea abajo" })
map("n", "<A-k>", "<cmd>m .-2<cr>==",    { desc = "Mover línea arriba" })
map("v", "<A-j>", ":m '>+1<cr>gv=gv",   { desc = "Mover selección abajo" })
map("v", "<A-k>", ":m '<-2<cr>gv=gv",   { desc = "Mover selección arriba" })

-- ── Utilidades ────────────────────────────────────────────────
map("n", "<Esc>",      "<cmd>nohl<cr>",      { desc = "Limpiar búsqueda" })
map("n", "<leader>w",  "<cmd>w<cr>",         { desc = "Guardar" })
map("n", "<leader>q",  "<cmd>q<cr>",         { desc = "Salir" })
map("n", "<leader>Q",  "<cmd>qa!<cr>",       { desc = "Forzar salir todo" })
