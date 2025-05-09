return {
  "saghen/blink.cmp",

  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    completion = {
      list = {
        selection = {
          preselect = false,
          auto_insert = false,
        },
      },
      documentation = {
        window = {
          border = "rounded",
        },
      },
      menu = {
        border = "rounded",
      },
    },

    signature = {
      window = {
        border = "rounded",
      },
    },
  },
}
