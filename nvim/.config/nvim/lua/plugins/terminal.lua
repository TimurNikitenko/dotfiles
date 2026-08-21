local function get_agy_bin()
  local path = vim.fn.exepath("agy")
  if path ~= "" then return path end
  if vim.fn.executable("/snap/antigravity-cli/current/bin/agy") == 1 then
    return "/snap/antigravity-cli/current/bin/agy"
  end
  if vim.fn.executable("/snap/antigravity-cli/15/bin/agy") == 1 then
    return "/snap/antigravity-cli/15/bin/agy"
  end
  return "agy"
end

local agy_instance = nil

local function toggle_agy(prompt)
  local ok, toggleterm = pcall(require, "toggleterm.terminal")
  if not ok then
    require("lazy").load({ plugins = { "toggleterm.nvim" } })
    toggleterm = require("toggleterm.terminal")
  end
  local Terminal = toggleterm.Terminal
  local agy_bin = get_agy_bin()

  if prompt and prompt ~= "" then
    local prompt_term = Terminal:new({
      cmd = agy_bin .. " --prompt-interactive " .. vim.fn.shellescape(prompt),
      hidden = true,
      direction = "float",
      close_on_exit = false,
      float_opts = { border = "curved" },
      on_open = function(term)
        vim.cmd("startinsert!")
      end,
    })
    prompt_term:toggle()
  else
    if not agy_instance then
      agy_instance = Terminal:new({
        cmd = agy_bin,
        hidden = true,
        direction = "float",
        close_on_exit = false,
        float_opts = { border = "curved" },
        on_open = function(term)
          vim.cmd("startinsert!")
          vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
        end,
      })
    end
    agy_instance:toggle()
  end
end

-- Register keymaps & user commands immediately upon loading
vim.keymap.set("n", "<leader>ag", function() toggle_agy() end, { desc = "Toggle Antigravity CLI (agy)", silent = true })
vim.keymap.set("n", "<leader>ai", function() toggle_agy() end, { desc = "Toggle Antigravity CLI (agy)", silent = true })

vim.api.nvim_create_user_command("Agy", function()
  toggle_agy()
end, { desc = "Toggle Antigravity CLI" })

vim.api.nvim_create_user_command("AgyAsk", function(args)
  toggle_agy(args.args)
end, { nargs = "*", desc = "Launch Antigravity CLI with prompt" })

return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    lazy = false,
    keys = {
      { "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>", desc = "Terminal Horizontal" },
      { "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", desc = "Terminal Float" },
    },
    config = function()
      require("toggleterm").setup({
        size = function(term)
          if term.direction == "horizontal" then return 15
          elseif term.direction == "vertical" then return vim.o.columns * 0.4 end
        end,
        open_mapping = [[<C-\>]],
        hide_numbers = true,
        shade_terminals = true,
        start_in_insert = true,
        insert_mappings = true,
        terminal_mappings = true,
        persist_size = true,
        direction = "horizontal",
        close_on_exit = true,
        float_opts = { border = "curved" },
      })

      function _G.set_terminal_keymaps()
        local opts = { buffer = 0 }
        vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], opts)
        vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
        vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], opts)
        vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], opts)
        vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], opts)
      end

      vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")
    end,
  },
}
