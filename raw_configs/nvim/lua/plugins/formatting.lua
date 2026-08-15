-- =============================================================
--  plugins/formatting.lua  |  Formatters y Linters
--  conform.nvim: estándar de la industria para formateo
--  nvim-lint: linting asíncrono sin bloquear el editor
-- =============================================================
return {

  -- ── Formatters (conform.nvim) ────────────────────────────────
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd   = { "ConformInfo" },
    keys  = {
      {
        "<leader>cf",
        function() require("conform").format({ async = true, lsp_fallback = true }) end,
        desc = "Formatear archivo",
      },
    },
    opts = {
      formatters_by_ft = {
        -- Lua
        lua = { "stylua" },

        -- Python (ruff primero — 100x más rápido que black)
        python = { "ruff_format", "black" },

        -- JavaScript / TypeScript / React / Next / NestJS
        javascript      = { "prettier" },
        typescript      = { "prettier" },
        javascriptreact = { "prettier" },
        typescriptreact = { "prettier" },

        -- Web
        html     = { "prettier" },
        css      = { "prettier" },
        scss     = { "prettier" },
        json     = { "prettier" },
        jsonc    = { "prettier" },
        yaml     = { "prettier" },
        markdown = { "prettier" },

        -- C# / .NET (CSharpier: formatter oficial de la comunidad .NET)
        cs = { "csharpier" },

        -- SQL
        sql = { "sql_formatter" },

        -- Shell / DevSecOps / IaC
        sh        = { "shfmt" },
        bash      = { "shfmt" },
        terraform = { "terraform_fmt" },
        hcl       = { "terraform_fmt" },
      },
      -- Formatear automáticamente al guardar
      format_on_save = {
        timeout_ms   = 3000,
        lsp_fallback = true,
      },
    },
  },

  -- ── Linters (nvim-lint) ──────────────────────────────────────
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lint = require("lint")

      lint.linters_by_ft = {
        python     = { "ruff" },              -- DevSecOps: ruff es 100x más rápido
        javascript = { "eslint_d" },          -- Daemon mode para velocidad
        typescript = { "eslint_d" },
        sh         = { "shellcheck" },        -- Análisis estático de shell scripts
        dockerfile = { "hadolint" },          -- Mejores prácticas y seguridad Docker
        terraform  = { "tflint" },            -- Linter profesional para Terraform
      }

      -- Trigger: al guardar, abrir y salir de insert
      vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
        group = vim.api.nvim_create_augroup("nvim_lint", { clear = true }),
        callback = function()
          require("lint").try_lint()
        end,
      })
    end,
  },
}
