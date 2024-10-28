local mocha = require("catppuccin.palettes").get_palette("mocha")

return {
  "petertriho/nvim-scrollbar",
  event = "BufReadPost",
  opts = {
    excluded_filetypes = {
      "prompt",
      "TelescopePrompt",
      "noice",
      "neo-tree",
      "dashboard",
      "alpha",
      "lazy",
      "mason",
      "DressingInput",
      "",
    },
    handlers = {
      cursor = true,
      diagnostic = true,
      handle = true,
      gitsigns = true,
    },
    marks = {
      Search = { color = mocha.peach },
      Error = { color = mocha.red },
      Warn = { color = mocha.yellow },
      Info = { color = mocha.teal },
      Hint = { color = mocha.blue },
      GitAdd = { color = mocha.green },
      GitChange = { color = mocha.yellow },
      GitDelete = { color = mocha.red },
    },
  },
}
