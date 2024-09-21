-- Read the docs: https://www.lunarvim.org/docs/configuration
-- Example configs: https://github.com/LunarVim/starter.lvim
-- Video Tutorials: https://www.youtube.com/watch?v=sFA9kX-Ud_c&list=PLhoH5vyxr6QqGu0i7tt_XoVK9v-KvZ3m6
-- Forum: https://www.reddit.com/r/lunarvim/
-- Discord: https://discord.com/invite/Xb9B4Ny
lvim.plugins = {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    opts = {
      flavour = "mocha"
    }
  }
}

lvim.colorscheme = "catppuccin"
lvim.format_on_save = true
-- This preselects the first autocompletion suggestion, allowing to press enter, space or <C-y> to insert the suggestion.
-- This saves a keystroke instead of having to first navigate up or down.
lvim.builtin.cmp.completion = { completeopt = "menu,menuone,noinsert" }
