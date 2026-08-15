-- =============================================================
--  plugins/ai.lua  |  IA y autocompletado inteligente
--  Supermaven: engine Rust, el más rápido del mercado
--  CodeCompanion: chat e inline edits usando Gemini / OpenAI / Ollama
-- =============================================================
return {
  {
    "supermaven-inc/supermaven-nvim",
    event = "InsertEnter",
    config = function()
      require("supermaven-nvim").setup({
        keymaps = {
          accept_suggestion = "<Tab>",    -- Aceptar sugerencia completa
          clear_suggestion  = "<C-]>",   -- Descartar sugerencia
          accept_word       = "<C-j>",   -- Aceptar siguiente palabra
        },
        -- No interferir con filetypes especiales
        ignore_filetypes = { "TelescopePrompt", "dbui", "dbout" },
      })
    end,
  },

  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "saghen/blink.cmp", -- Integración con autocompletado blink
    },
    event = "VeryLazy",
    config = function()
      require("codecompanion").setup({
        opts = {
          language = "Spanish",
        },
        strategies = {
          chat = {
            adapter = "gemini",
          },
          inline = {
            adapter = "gemini",
          },
          agent = {
            adapter = "gemini",
          },
        },
        adapters = {
          http = {
            gemini = function()
              return require("codecompanion.adapters").extend("gemini", {
                schema = {
                  model = {
                    default = "gemini-3.5-flash", -- Usar Flash para evitar límites de cuota (15 RPM / 1500 RPD)
                    choices = {
                      "gemini-3.5-flash",
                      "gemini-3.1-flash-lite",
                      "gemini-3.1-pro-preview",
                      "gemini-2.0-flash",
                    },
                  },
                },
              })
            end,
          },
        },
        prompt_library = {
          ["Auditar Seguridad IaC (DevSecOps)"] = {
            strategy = "chat",
            description = "Audita la seguridad y mejores prácticas de archivos IaC (Docker, K8s, Terraform)",
            opts = {
              index = 10,
              is_default = true,
              is_slash_cmd = true,
              short_name = "iac_sec",
              auto_submit = true,
            },
            prompts = {
              {
                role = "system",
                content = "Eres un ingeniero DevSecOps senior de élite. Tu objetivo es auditar código de infraestructura como código (IaC) para identificar vulnerabilidades de seguridad, malas prácticas, mala optimización y proponer soluciones seguras según los estándares de la industria.",
              },
              {
                role = "user",
                content = "Audita de forma exhaustiva el siguiente código de infraestructura. Analiza:\n1. Problemas de seguridad (privilegios elevados, contraseñas hardcoded, puertos vulnerables, etc.).\n2. Optimización y límites de recursos.\n3. Cumplimiento de mejores prácticas estándar.\n\nProporciona una explicación concisa del impacto de cada vulnerabilidad y el código modificado y seguro para corregirlo.\n\nAquí está el código:\n\n```\n%CODE\n```",
              },
            },
          },
          ["Explicar Concepto Avanzado"] = {
            strategy = "chat",
            description = "Explica detalladamente un concepto complejo desde las bases antes de profundizar",
            opts = {
              index = 11,
              is_default = true,
              is_slash_cmd = true,
              short_name = "explain",
              auto_submit = true,
            },
            prompts = {
              {
                role = "system",
                content = "Eres un mentor y profesor de programación altamente pedagógico. Tu objetivo es desglosar conceptos complejos de algoritmos, arquitectura de software, bases de datos o redes desde lo más básico (usando analogías sencillas y cotidianas) antes de entrar en detalles técnicos rigurosos y código.",
              },
              {
                role = "user",
                content = "Explica el siguiente concepto o fragmento de código de la forma más pedagógica posible. Comienza con una analogía simple de la vida real, luego explica el funcionamiento conceptual básico y finalmente detalla los aspectos avanzados y técnicos del mismo.\n\nConcepto/Código:\n\n```\n%CODE\n```",
              },
            },
          },
          ["Generar Pruebas Unitarias"] = {
            strategy = "chat",
            description = "Genera pruebas unitarias robustas (pytest, jest, vitest o dotnet) para el código seleccionado",
            opts = {
              index = 12,
              is_default = true,
              is_slash_cmd = true,
              short_name = "tests",
              auto_submit = true,
            },
            prompts = {
              {
                role = "system",
                content = "Eres un ingeniero de control de calidad (QA) y desarrollador senior experto en pruebas automatizadas. Tu objetivo es escribir casos de prueba exhaustivos y limpios.",
              },
              {
                role = "user",
                content = "Genera un conjunto completo de pruebas unitarias para el código seleccionado. Identifica el lenguaje del código y utiliza el framework estándar correspondiente (ej. pytest para Python, Jest/Vitest para JS/TS, xUnit/nUnit para C#).\n\nIncluye en tus pruebas:\n1. Casos felices (happy paths).\n2. Casos límite (edge cases) y valores extremos.\n3. Manejo de excepciones y estados de error.\n4. Mocks o Stubs si el código realiza llamadas a APIs o bases de datos.\n\nAquí está el código:\n\n```\n%CODE\n```",
              },
            },
          },
          ["Revisión de Código y Complejidad (Big O)"] = {
            strategy = "chat",
            description = "Analiza la legibilidad del código, principios Clean Code y la complejidad algorítmica Big O",
            opts = {
              index = 13,
              is_default = true,
              is_slash_cmd = true,
              short_name = "review",
              auto_submit = true,
            },
            prompts = {
              {
                role = "system",
                content = "Eres un Tech Lead y arquitecto de software de élite. Tu objetivo es revisar código enfocado en la mantenibilidad, legibilidad, optimización algorítmica y buenas prácticas de ingeniería de software.",
              },
              {
                role = "user",
                content = "Realiza una revisión técnica profunda del código seleccionado. Analiza:\n1. Complejidad algorítmica (Tiempo y Espacio) detallada usando la notación Big O (ej. O(N), O(log N)).\n2. Cumplimiento de principios de Clean Code, SOLID y DRY (Don't Repeat Yourself).\n3. Oportunidades de optimización y simplificación.\n4. Errores potenciales latentes.\n\nProporciona una tabla resumen de tus observaciones y una versión refactorizada y optimizada del código.\n\nAquí está el código:\n\n```\n%CODE\n```",
              },
            },
          },
          ["Generar Script de Automatización"] = {
            strategy = "chat",
            description = "Genera un script robusto de automatización (Bash o Python) con manejo de errores y logs",
            opts = {
              index = 14,
              is_default = true,
              is_slash_cmd = true,
              short_name = "script",
              auto_submit = true,
            },
            prompts = {
              {
                role = "system",
                content = "Eres un ingeniero DevOps sénior experto en automatización de sistemas y scripting. Tu objetivo es generar scripts robustos, limpios y listos para producción.",
              },
              {
                role = "user",
                content = "Escribe un script de automatización completo y robusto para realizar la siguiente tarea. Determina si es mejor usar Bash o Python según el contexto del usuario.\n\nEl script debe incluir obligatoriamente:\n1. Argumentos de entrada bien analizados (usando getopt o argparse).\n2. Trapeo y manejo de errores (ej. set -euo pipefail en Bash o bloques try-except en Python).\n3. Logs claros y con timestamps para registrar el progreso y errores.\n4. Documentación clara y comentarios de uso en el encabezado.\n\nAquí está la especificación o requerimiento:\n\n%CODE",
              },
            },
          },
        },
      })
    end,
    keys = {
      { "<leader>ac", "<cmd>CodeCompanionChat Toggle<cr>", desc = "IA: Chat interactivo", mode = { "n", "v" } },
      { "<leader>ai", "<cmd>CodeCompanion<cr>", desc = "IA: Inline (edición en sitio)", mode = { "n", "v" } },
      { "<leader>ap", "<cmd>CodeCompanionActions<cr>", desc = "IA: Prompt Library / Acciones", mode = { "n", "v" } },
      -- Mapeos rápidos para flujo con selección visual
      { "ga", "<cmd>CodeCompanionChat Add<cr>", desc = "IA: Agregar código seleccionado al chat", mode = { "v" } },
      { "ge", "<cmd>CodeCompanion<cr>", desc = "IA: Edición inline sobre selección", mode = { "v" } },
    },
  },
}
