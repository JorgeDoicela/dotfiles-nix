-- =============================================================
--  plugins/git.lua  |  Integración con Git
--  gitsigns: indicadores en gutter
--  lazygit: TUI completo de Git integrado en Neovim
-- =============================================================
return {

  -- ── Gitsigns: indicadores de cambios en el gutter ────────────
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add          = { text = "▎" },
        change       = { text = "▎" },
        delete       = { text = "" },
        topdelete    = { text = "" },
        changedelete = { text = "▎" },
        untracked    = { text = "▎" },
      },
      on_attach = function(bufnr)
        local gs  = package.loaded.gitsigns
        local map = function(mode, keys, func, desc)
          vim.keymap.set(mode, keys, func, { buffer = bufnr, desc = "Git: " .. desc })
        end

        -- Navegar entre hunks
        map("n", "]g", gs.next_hunk,             "Hunk siguiente")
        map("n", "[g", gs.prev_hunk,             "Hunk anterior")

        -- Staging granular (por hunk, no por archivo completo)
        map("n", "<leader>gs", gs.stage_hunk,    "Stage hunk")
        map("n", "<leader>gr", gs.reset_hunk,    "Reset hunk")
        map("v", "<leader>gs", function()
          gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, "Stage hunk (visual)")

        -- Buffer completo
        map("n", "<leader>gS", gs.stage_buffer,  "Stage buffer")
        map("n", "<leader>gR", gs.reset_buffer,  "Reset buffer")
        map("n", "<leader>gu", gs.undo_stage_hunk, "Undo stage hunk")

        -- Vista y blame
        map("n", "<leader>gp", gs.preview_hunk,  "Preview hunk")
        map("n", "<leader>gb", function()
          gs.blame_line({ full = true })
        end, "Blame línea")
        map("n", "<leader>gd", gs.diffthis,      "Diff this")
        map("n", "<leader>gD", function()
          gs.diffthis("~")
        end, "Diff vs HEAD~1")
      end,
    },
  },

  -- ── LazyGit: TUI completo de Git ─────────────────────────────
  {
    "kdheepak/lazygit.nvim",
    cmd          = { "LazyGit", "LazyGitConfig", "LazyGitCurrentFile", "LazyGitFilter" },
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>gg", "<cmd>LazyGit<cr>",            desc = "LazyGit" },
      { "<leader>gf", "<cmd>LazyGitCurrentFile<cr>", desc = "LazyGit (archivo actual)" },
    },
  },
}
