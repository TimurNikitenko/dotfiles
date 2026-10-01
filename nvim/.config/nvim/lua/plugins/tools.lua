return {
  {
    "lewis6991/gitsigns.nvim",
    config = function() require("gitsigns").setup() end,
  },
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function() require("nvim-autopairs").setup() end,
  },
  {
    "echasnovski/mini.comment",
    version = "*",
    event = "VeryLazy",
    config = function()
      require("mini.comment").setup({
        options = {
          custom_commentstring = function()
            return (vim.bo.commentstring and vim.bo.commentstring ~= "") and vim.bo.commentstring or "# %s"
          end,
        },
        mappings = {
          comment = "gc",
          comment_line = "gcc",
          comment_visual = "gc",
          textobject = "gc",
        },
      })

      -- Keymap for <leader>/ to toggle comment on current line (Normal) or selection (Visual)
      vim.keymap.set("n", "<leader>/", "gcc", { remap = true, desc = "Toggle comment line" })
      vim.keymap.set("v", "<leader>/", "gc", { remap = true, desc = "Toggle comment selection" })
    end,
  },
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {},
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
      { "<leader>xd", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics" },
    },
  },
}
