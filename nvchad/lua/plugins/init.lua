return {
  -- {
  --   "stevearc/conform.nvim",
  --   event = "BufWritePre",
  --   opts = require "configs.conform",
  -- },
  --
  -- {
  --   "neovim/nvim-lspconfig",
  --   config = function()
  --     require "configs.lspconfig"
  --   end,
  -- },

  { import = "nvchad.blink.lazyspec" },

  {
    "saghen/blink.pairs",
    build = function() require('blink.pairs')
.build():pwait(60000) end 
    dependencies = "saghen/blink.download",
    event = { "BufNewFile", "BufReadPost" },
    opts = {
      highlights = {
        enabled = true,
        groups = {
          "BlinkPairsRed",
          "BlinkPairsOrange",
          "BlinkPairsYellow",
          "BlinkPairsGreen",
          "BlinkPairsCyan",
          "BlinkPairsBlue",
          "BlinkPairsViolet",
        },
      },
    },
  },

  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    ---@type snacks.Config

    opts = {
      image = { enabled = true },
      notifier = { enabled = true },
      animate = { enabled = true },
      scroll = { enabled = true },
      words = { enabled = true },
      lazygit = { enabled = true },
      indent = { enabled = true },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "vim",
        "lua",
        "vimdoc",
        "html",
        "css",
        "python",
        "markdown",
        "markdown_inline",
      },
    },
  },
}
