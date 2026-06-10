-- ~/.config/nvim/lua/core/options.lua

-- ── UI & View Layer ────────────────────────────────────────────────────────
vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.signcolumn = "yes"
vim.opt.cursorline = true
vim.opt.termguicolors = true
vim.opt.showmode = false
vim.opt.cmdheight = 1
vim.opt.laststatus = 3
vim.opt.showtabline = 0
vim.opt.numberwidth = 3
vim.opt.pumheight = 10 -- Reasonable popup height; 1 was unusably restrictive
vim.opt.completeopt = { "menu", "menuone", "noselect" }
vim.opt.conceallevel = 0
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.breakindent = true
-- vim.opt.smoothscroll = true      -- Elegant step scrolling when navigating long wrapped lines
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.fillchars = { eob = " " }

-- White-space Visualizers
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- ── Structural Editing ──────────────────────────────────────────────────────
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smarttab = true
vim.opt.autoindent = true
vim.opt.virtualedit = "block"
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"

-- ── Search Matchers ─────────────────────────────────────────────────────────
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.inccommand = "split"

-- ── Window Split Layouts ────────────────────────────────────────────────────
vim.opt.splitright = true
vim.opt.splitbelow = true

-- ── Integrity & Persistence ─────────────────────────────────────────────────
vim.opt.undofile = true
vim.opt.undodir = vim.fn.stdpath("data") .. "/undo"
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false

-- ── Performance Core Timers ─────────────────────────────────────────────────
vim.opt.updatetime = 200
vim.opt.timeoutlen = 300
vim.opt.autoread = true
vim.opt.fileencoding = "utf-8"

-- Global default; per-buffer markdown / tex files override this with the
-- two-tier tier1,tier2 list via core.spellfile.resolve().
vim.opt.spellfile = vim.fn.stdpath("config") .. "/spell/en.utf-8.add"
