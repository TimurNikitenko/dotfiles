-- Глобальный патч совместимости для Neovim 0.11+
if vim.treesitter then
    vim.treesitter.ft_to_lang = vim.treesitter.ft_to_lang or function(ft)
        local ok, lang = pcall(function()
            return require("vim.treesitter.language").get_lang(ft)
        end)
        return (ok and lang) or ft
    end
end

-- Динамическое добавление пользовательских директорий бинарников в PATH
local home = vim.fn.expand("~")
local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"
local real_home = (os.getenv("HOME") or ""):gsub("/snap/[^/]+/common", "")
local node_bin = real_home .. "/.nodejs/bin"
local user_bins = { mason_bin, node_bin, home .. "/.local/bin", home .. "/bin" }
for _, dir in ipairs(user_bins) do
    if vim.fn.isdirectory(dir) == 1 and not (vim.env.PATH or ""):find(dir, 1, true) then
        vim.env.PATH = dir .. ":" .. (vim.env.PATH or "")
        vim.fn.setenv("PATH", vim.env.PATH)
    end
end

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Delete to black hole register (doesn't overwrite clipboard)
vim.keymap.set({'n', 'v'}, '<leader>d', '"_d', { desc = "Delete without copying" })
vim.keymap.set('n', 'gx', function()
  local url = vim.fn.expand('<cWORD>') -- берём слово под курсором
  vim.ui.open(url)
end, { desc = 'Open URL under cursor' })

local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true
opt.wrap = false

opt.swapfile = false
opt.backup = false
opt.undofile = true
opt.undodir = home .. "/.vim/undodir"

opt.hlsearch = false
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true

opt.termguicolors = true
opt.scrolloff = 8
opt.signcolumn = "yes"
opt.cursorline = true

opt.updatetime = 50
opt.timeoutlen = 750
opt.splitright = true
opt.splitbelow = true
opt.clipboard = "unnamedplus"

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)
vim.api.nvim_create_autocmd("FileType", {
  pattern = "json", -- или "*", если хотите для всех файлов с Treesitter
  callback = function()
    vim.schedule(function()
      vim.wo.foldmethod = "expr"
      vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()" -- актуальная функция
      vim.wo.foldlevel = 99
      vim.wo.foldenable = true
    end)
  end,
})
-- Функция для экранирования специальных символов в langmap
local function escape_langmap(str)
  -- Эти символы являются специальными в langmap и должны быть экранированы
  local escape_chars = [[;,."|\]]
  return vim.fn.escape(str, escape_chars)
end

-- Определяем строки символов
-- Русские символы (то, что вы нажимаете)
local ru = [[ёйцукенгшщзхъфывапролджэячсмитьбю.Ё"№;:?]]
-- Соответствующие английские символы (то, во что они должны превращаться)
local en = [[`qwertyuiop[]asdfghjkl;'zxcvbnm,./~@#$^&]]

-- Добавляем пары в langmap
vim.opt.langmap:append(vim.fn.join({
  escape_langmap(ru) .. ";" .. escape_langmap(en),
}, ","))

require("lazy").setup({
    spec = {
        { import = "plugins" },
    },
    install = { colorscheme = { "catppuccin" } },
    checker = { enabled = true, notify = false },
})
