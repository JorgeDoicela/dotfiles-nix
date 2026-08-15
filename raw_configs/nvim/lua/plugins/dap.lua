-- =============================================================
--  plugins/dap.lua  |  Debug Adapter Protocol (Depuración)
-- =============================================================
return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      -- Interfaz gráfica para depuración
      {
        "rcarriga/nvim-dap-ui",
        dependencies = { "nvim-neotest/nvim-nio" },
        opts = {
          floating = { border = "rounded" },
          layouts = {
            {
              elements = {
                { id = "scopes", size = 0.25 },
                { id = "breakpoints", size = 0.25 },
                { id = "stacks", size = 0.25 },
                { id = "watches", size = 0.25 },
              },
              position = "left",
              size = 40,
            },
            {
              elements = {
                { id = "repl", size = 0.5 },
                { id = "console", size = 0.5 },
              },
              position = "bottom",
              size = 10,
            },
          },
        },
        config = function(_, opts)
          local dap = require("dap")
          local dapui = require("dapui")
          dapui.setup(opts)

          -- Auto abrir y cerrar la interfaz gráfica al depurar
          dap.listeners.after.event_initialized["dapui_config"] = function()
            dapui.open()
          end
          dap.listeners.before.event_terminated["dapui_config"] = function()
            dapui.close()
          end
          dap.listeners.before.event_exited["dapui_config"] = function()
            dapui.close()
          end
        end,
      },

      -- Integración con Mason para auto-instalación de depuradores
      {
        "jay-babu/mason-nvim-dap.nvim",
        dependencies = { "williamboman/mason.nvim" },
        opts = {
          automatic_installation = true,
          ensure_installed = {
            "debugpy",    -- Python
            "netcoredbg", -- C# / .NET
          },
          handlers = {},
        },
      },
    },
    -- Atajos de teclado profesionales (estilo VS Code / IDEs clásicos)
    keys = {
      { "<F5>",      function() require("dap").continue() end,          desc = "Debug: Iniciar/Continuar" },
      { "<F10>",     function() require("dap").step_over() end,         desc = "Debug: Paso sobre (Step Over)" },
      { "<F11>",     function() require("dap").step_into() end,         desc = "Debug: Paso dentro (Step Into)" },
      { "<F12>",     function() require("dap").step_out() end,          desc = "Debug: Paso fuera (Step Out)" },
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Debug: Alternar Breakpoint" },
      {
        "<leader>dB",
        function()
          vim.ui.input({ prompt = "Condición de parada: " }, function(input)
            if input and input ~= "" then
              require("dap").set_breakpoint(input)
            end
          end)
        end,
        desc = "Debug: Breakpoint Condicional",
      },
      { "<leader>du", function() require("dapui").toggle() end,          desc = "Debug: Alternar UI" },
      { "<leader>dr", function() require("dap").repl.open() end,         desc = "Debug: Abrir REPL" },
      { "<leader>dl", function() require("dap").run_last() end,          desc = "Debug: Ejecutar última depuración" },
    },
    config = function()
      -- Estética: íconos bonitos en la barra de números/gutter
      vim.fn.sign_define("DapBreakpoint",          { text = "🔴", texthl = "", linehl = "", numhl = "" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "🟡", texthl = "", linehl = "", numhl = "" })
      vim.fn.sign_define("DapLogPoint",             { text = "📝", texthl = "", linehl = "", numhl = "" })
      vim.fn.sign_define("DapStopped",              { text = "➡️", texthl = "GitSignsAdd", linehl = "Visual", numhl = "" })
      vim.fn.sign_define("DapBreakpointRejected",   { text = "🚫", texthl = "", linehl = "", numhl = "" })
    end,
  },
}
