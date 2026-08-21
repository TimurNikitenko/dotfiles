return {
  {
    "3rd/image.nvim",
    build = false, -- Disable automatic rock build step to prevent build failures
    event = "VeryLazy",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    opts = {
      backend = "kitty", -- WezTerm natively supports the Kitty graphics protocol
      integrations = {
        markdown = {
          enabled = true,
          clear_in_insert_mode = false,
          download_remote_images = true,
          only_render_image_at_cursor = false,
          filetypes = { "markdown", "vimwiki" },
        },
        html = {
          enabled = true,
        },
        css = {
          enabled = true,
        },
      },
      max_width = 100,
      max_height = 25,
      max_width_window_percentage = math.huge,
      max_height_window_percentage = math.huge,
      window_overlap_clear_enabled = true,
      window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
      editor_only_render_when_focused = false,
      tmux_show_only_in_active_window = false,
    },
  },
}
