-- =============================================================
--  plugins/testing.lua  |  Ejecutor de pruebas unitarias
-- =============================================================
return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      -- Adaptadores de lenguajes para pruebas
      "nvim-neotest/neotest-python",
      "haydenmeade/neotest-jest",
      "marilari88/neotest-vitest",
      "Issafalcon/neotest-dotnet",
    },
    config = function()
      local neotest = require("neotest")

      neotest.setup({
        adapters = {
          -- Python (Pytest / Unittest)
          require("neotest-python")({
            dap = { justMyCode = false },
          }),
          -- JS / TS (Jest)
          require("neotest-jest")({
            jestConfigFile = function(file)
              if string.find(file, "/apps/") or string.find(file, "/packages/") then
                return string.match(file, "(.-/[^/]+/[^/]+/)") .. "jest.config.js"
              end
              return vim.fn.getcwd() .. "/jest.config.js"
            end,
          }),
          -- JS / TS (Vitest)
          require("neotest-vitest"),
          -- C# / .NET (xUnit / NUnit / MSTest)
          require("neotest-dotnet")({
            dap = {
              type = "coreclr",
            },
          }),
        },
        status = { virtual_text = true },
        output = { open_on_run = true },
        quickfix = {
          open = function()
            -- Integrar con Trouble si está disponible
            local ok, _ = pcall(require, "trouble")
            if ok then
              vim.cmd("Trouble qflist open")
            else
              vim.cmd("copen")
            end
          end,
        },
      })
    end,
    -- Atajos de teclado para pruebas unitarias
    keys = {
      { "<leader>tr", function() require("neotest").run.run() end,                               desc = "Test: Ejecutar el más cercano" },
      { "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end,             desc = "Test: Ejecutar archivo actual" },
      { "<leader>td", function() require("neotest").run.run({ strategy = "dap" }) end,           desc = "Test: Depurar el más cercano" },
      { "<leader>ts", function() require("neotest").summary.toggle() end,                         desc = "Test: Alternar panel resumen" },
      { "<leader>to", function() require("neotest").output.open({ enter = true, auto_close = true }) end, desc = "Test: Ver salida en flotante" },
      { "<leader>tS", function() require("neotest").run.stop() end,                               desc = "Test: Detener ejecución" },
    },
  },
}
