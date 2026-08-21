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
opt.timeoutlen = 300
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

require("lazy").setup({
    spec = {
        { import = "plugins" },
    },
    install = { colorscheme = { "catppuccin" } },
    checker = { enabled = true, notify = false },
})
