-- ~/.config/nvim/init.lua

-- Enable the experimental high-speed Lua byte-compiler cache
vim.loader.enable()

vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("core.options")
require("core.keymaps")
require("core.autocmds")

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
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
  { import = "plugins" },
}, {
  -- Req 6: Default version constraint. "*" resolves to the highest semver
  -- tag (= latest stable release). Plugins that need a tighter constraint
  -- (e.g. "1.*" for known majors, "1.*" for blink.cmp) override this in
  -- their own spec. :Lazy sync / :Lazy update still honour these overrides.
  defaults = {
    version = "*",
  },

  checker = {
    enabled = true,
    frequency = 86400,
    notify = false,
  },

  change_detection = {
    notify = false,
  },

  install = {
    colorscheme = { "catppuccin", "habamax" },
  },

  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "rplugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
