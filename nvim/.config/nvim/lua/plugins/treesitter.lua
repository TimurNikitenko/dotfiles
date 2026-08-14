return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      local ok, ts = pcall(require, "nvim-treesitter.configs")
      if not ok then
        ok, ts = pcall(require, "nvim-treesitter")
      end

      if ok and ts.setup then
        ts.setup({
          ensure_installed = {
            "python", "lua", "vim", "vimdoc", "query", "markdown",
            "markdown_inline", "yaml", "json", "toml"
          },
          auto_install = true,
          highlight = { enable = true },
          indent = { enable = true },
        })
      end
    end,
  },
}
