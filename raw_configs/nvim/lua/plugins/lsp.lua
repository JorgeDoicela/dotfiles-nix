-- =============================================================
--  plugins/lsp.lua  |  Language Server Protocol
--  Stack: Python · JS/TS/React/Next/NestJS · C#/.NET · DevSecOps
-- =============================================================
return {
  {
    "williamboman/mason.nvim",
    cmd = { "Mason", "MasonInstall", "MasonUpdate", "MasonUninstall", "MasonLog" },
    opts = {
      ui = {
        border = "rounded",
        icons  = {
          package_installed   = "✓",
          package_pending     = "➜",
          package_uninstalled = "✗",
        },
      },
    },
  },

  {
    "neovim/nvim-lspconfig",
    event        = { "BufReadPre", "BufNewFile" },
    cmd          = { "LspInfo", "LspStart", "LspRestart" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "Hoffs/omnisharp-extended-lsp.nvim",
    },
    config = function()
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

      -- ── LspAttach: keymaps que se activan al conectar cliente LSP ──
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
        callback = function(args)
          local bufnr = args.buf
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
        end,
      })

      -- ── Capacidades globales: integración con blink.cmp ────
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local ok_blink, blink = pcall(require, "blink.cmp")
      if ok_blink then
        capabilities = blink.get_lsp_capabilities(capabilities)
      end
      vim.lsp.config("*", { capabilities = capabilities })

      -- ── Configuraciones específicas por servidor ───────────

      -- TypeScript / JavaScript (ts_ls)
      vim.lsp.config("ts_ls", {
        settings = {
          typescript = {
            inlayHints = {
              includeInlayParameterNameHints    = "all",
              includeInlayFunctionReturnTypeHints = true,
            },
          },
        },
      })

      -- ESLint (autofix al guardar)
      vim.lsp.config("eslint", {
        on_attach = function(_, bufnr)
          vim.api.nvim_create_autocmd("BufWritePre", {
            buffer   = bufnr,
            callback = function() vim.cmd("EslintFixAll") end,
          })
        end,
      })

      -- JSON: schemas con protección defensiva pcall
      local schemastore_ok, schemastore = pcall(require, "schemastore")
      vim.lsp.config("jsonls", {
        settings = {
          json = {
            schemas = schemastore_ok and schemastore.json.schemas() or {},
            validate = { enable = true },
          },
        },
      })

      -- YAML: schemas para K8s y GitHub Actions
      vim.lsp.config("yamlls", {
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

      -- Python: pyright
      vim.lsp.config("pyright", {
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

      -- Lua: desarrollo de Neovim
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            workspace   = { checkThirdParty = false },
            telemetry   = { enable = false },
            diagnostics = { globals = { "vim" } },
          },
        },
      })

      -- C# / .NET: omnisharp con omnisharp_extended seguro
      vim.lsp.config("omnisharp", {
        handlers = {
          ["textDocument/definition"] = function(...)
            local ok_omni, omni = pcall(require, "omnisharp_extended")
            if ok_omni then
              return omni.handler(...)
            end
            return vim.lsp.handlers["textDocument/definition"](...)
          end,
        },
      })

      -- ── Activar servidores declarados ──────────────────────
      local servers = {
        "ts_ls",
        "eslint",
        "html",
        "cssls",
        "jsonls",
        "tailwindcss",
        "pyright",
        "omnisharp",
        "dockerls",
        "docker_compose_language_service",
        "yamlls",
        "bashls",
        "terraformls",
        "lua_ls",
      }
      vim.lsp.enable(servers)

      -- ── Estilo de diagnósticos ──────────────────────────────
      vim.diagnostic.config({
        virtual_text     = { prefix = "●" },
        signs            = true,
        underline        = true,
        update_in_insert = false,
        severity_sort    = true,
        float            = { border = "rounded", source = "always" },
      })
    end,
  },

  -- Schemas de JSON/YAML (package.json, docker-compose, k8s...)
  { "b0o/schemastore.nvim", lazy = true },
}
