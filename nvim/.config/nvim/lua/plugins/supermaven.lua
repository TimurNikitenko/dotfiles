return {
  {
    "supermaven-inc/supermaven-nvim",
    lazy = false,
    opts = {
      keymaps = {
        accept_suggestion = "<C-g>",
        clear_suggestion = "<C-x>",
        accept_word = "<C-j>",
      },
      ignore_filetypes = {},
      color = {
        suggestion_color = "#89b4fa",
        cterm = 244,
      },
      disable_inline_completion = false,
      disable_keymaps = false,
    },
  },
}
