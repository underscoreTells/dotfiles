return {
  "yetone/avante.nvim",
  build = vim.fn.has("win32") ~= 0 and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
    or "make",
  event = "VeryLazy",
  version = false,
  ---@module 'avante'
  ---@type avante.Config
  opts = {
    instructions_file = "avante.md",
    provider = "glm_4_6",
    providers = require("plugins.avante.providers"),
    acp_providers = require("plugins.avante.acp"),
  },
  dependencies = require("plugins.avante.dependencies"),
}
