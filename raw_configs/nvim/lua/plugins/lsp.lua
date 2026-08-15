-- =============================================================
--  plugins/lsp.lua  |  Language Server Protocol
--  Stack: Python · JS/TS/React/Next/NestJS · C#/.NET · DevSecOps
-- =============================================================
return {
  {
    "neovim/nvim-lspconfig",
    event        = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()

      -- ── Mason: gestor de LSPs, formatters y linters ────────
      require("mason").setup({
        ui = {
          border = "rounded",
          icons  = {
            package_installed   = "✓",
            package_pending     = "➜",
            package_uninstalled = "✗",
          },
        },
      })

      require("mason-lspconfig").setup({
        automatic_installation = true,
        ensure_installed = {
          -- JavaScript / TypeScript / Node / React / Next / NestJS
          "ts_ls",          -- TypeScript Language Server
          "eslint",         -- Linter/fixer para JS/TS
          "html",           -- HTML
          "cssls",          -- CSS / SCSS / Less
          "jsonls",         -- JSON con schema validation
          "tailwindcss",    -- TailwindCSS intellisense

          -- Python (DevSecOps + Data + Backend)
          "pyright",        -- Type-checking estático

          -- C# / .NET
          "omnisharp",      -- LSP oficial de Microsoft para .NET

          -- DevSecOps / Infrastructure
          "dockerls",                        -- Dockerfile
          "docker_compose_language_service", -- docker-compose.yml
          "yamlls",                          -- YAML (K8s, CI/CD, GitHub Actions)
          "bashls",                          -- Bash / Shell scripts
          "terraformls",                     -- Terraform / IaC

          -- Lua (configuración de Neovim)
          "lua_ls",
        },
      })

      -- ── on_attach: keymaps que se activan al conectar LSP ──
      local on_attach = function(_, bufnr)
        local map = function(keys, func, desc)
          vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
        end

        -- Navegación de código
        map("gd",          vim.lsp.buf.definition,      "Ir a definición")
        map("gD",          vim.lsp.buf.declaration,     "Ir a declaración")
        map("gr",          vim.lsp.buf.references,      "Ver referencias")
        map("gi",          vim.lsp.buf.implementation,  "Ir a implementación")
        map("K",           vim.lsp.buf.hover,            "Documentación hover")
        map("<C-k>",       vim.lsp.buf.signature_help,  "Ayuda de firma")

        -- Refactoring
        map("<leader>ca",  vim.lsp.buf.code_action,     "Code action")
        map("<leader>rn",  vim.lsp.buf.rename,           "Renombrar símbolo")
        map("<leader>D",   vim.lsp.buf.type_definition, "Ir al tipo")

        -- Diagnósticos
        map("<leader>e",   vim.diagnostic.open_float,   "Diagnóstico flotante")
        map("[d",          vim.diagnostic.goto_prev,    "Diagnóstico anterior")
        map("]d",          vim.diagnostic.goto_next,    "Diagnóstico siguiente")
      end

      -- ── Capacidades: integración con blink.cmp ─────────────
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local ok, blink = pcall(require, "blink.cmp")
      if ok then
        capabilities = blink.get_lsp_capabilities(capabilities)
      end

      local lspconfig = require("lspconfig")

      -- Servidores con configuración por defecto
      local default_servers = {
        "html", "cssls", "dockerls",
        "docker_compose_language_service", "bashls", "tailwindcss",
        "terraformls",
      }
      for _, server in ipairs(default_servers) do
        lspconfig[server].setup({ on_attach = on_attach, capabilities = capabilities })
      end

      -- ── Configuraciones específicas por lenguaje ───────────

      -- TypeScript / JavaScript (ts_ls)
      lspconfig.ts_ls.setup({
        on_attach    = on_attach,
        capabilities = capabilities,
        settings = {
          typescript = {
            inlayHints = {
              includeInlayParameterNameHints    = "all",
              includeInlayFunctionReturnTypeHints = true,
            },
          },
        },
      })

      -- ESLint (actúa como LSP para errores de linting)
      lspconfig.eslint.setup({
        on_attach = function(client, bufnr)
          on_attach(client, bufnr)
          -- Autofix al guardar
          vim.api.nvim_create_autocmd("BufWritePre", {
            buffer   = bufnr,
            callback = function() vim.cmd("EslintFixAll") end,
          })
        end,
        capabilities = capabilities,
      })

      -- JSON: habilitar schemas (package.json, tsconfig, etc.)
      lspconfig.jsonls.setup({
        on_attach    = on_attach,
        capabilities = capabilities,
        settings = {
          json = {
            schemas = require("schemastore") and require("schemastore").json.schemas() or {},
            validate = { enable = true },
          },
        },
      })

      -- YAML: schemas para K8s y GitHub Actions
      lspconfig.yamlls.setup({
        on_attach    = on_attach,
        capabilities = capabilities,
        settings = {
          yaml = {
            schemaStore = { enable = true },
            schemas = {
              ["https://raw.githubusercontent.com/instrumenta/kubernetes-json-schema/master/v1.18.0-standalone-strict/all.json"] = "/*.k8s.yaml",
              ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*.yml",
            },
          },
        },
      })

      -- Python: pyright con configuración para DevSecOps
      lspconfig.pyright.setup({
        on_attach    = on_attach,
        capabilities = capabilities,
        settings = {
          python = {
            analysis = {
              typeCheckingMode = "basic",
              autoSearchPaths  = true,
              useLibraryCodeForTypes = true,
            },
          },
        },
      })

      -- Lua: configurado para desarrollo de Neovim
      lspconfig.lua_ls.setup({
        on_attach    = on_attach,
        capabilities = capabilities,
        settings = {
          Lua = {
            workspace  = { checkThirdParty = false },
            telemetry  = { enable = false },
            diagnostics = { globals = { "vim" } },
          },
        },
      })

      -- C# / .NET: omnisharp
      lspconfig.omnisharp.setup({
        on_attach    = on_attach,
        capabilities = capabilities,
        handlers = {
          -- Sobrescribir go-to-definition para usar implementación de omnisharp
          ["textDocument/definition"] = function(...)
            return require("omnisharp_extended").handler(...)
          end,
        },
      })

      -- ── Estilo de diagnósticos ──────────────────────────────
      vim.diagnostic.config({
        virtual_text  = { prefix = "●" },
        signs         = true,
        underline     = true,
        update_in_insert = false,
        severity_sort = true,
        float = { border = "rounded", source = "always" },
      })
    end,
  },

  -- Schemas de JSON/YAML (package.json, docker-compose, k8s...)
  { "b0o/schemastore.nvim", lazy = true },
}
