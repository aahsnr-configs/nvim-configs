return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    opts = require "configs.conform",
  },

  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  { import = "nvchad.blink.lazyspec" },

  {
    "saghen/blink.pairs",
    version = "*",
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
    event = "VeryLazy",
    opts = {
      animate = {
        enabled = true,
        duration = 20,
        easing = "linear",
        fps = 60,
      },
      scroll = {
        enabled = true,
        animate = {
          duration = {
            step = 15,
            total = 250,
          },
          easing = "outQuad",
        },
        animate_repeat = {
          delay = 100,
          duration = { step = 5, total = 50 },
          easing = "outQuad",
        },
        image = {
          resolve = function(path, src)
            if require("obsidian.api").path_is_note(path) then
              return require("obsidian.api").resolve_image_path(src)
            end
          end,
        },
      },
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
      },
    },
  },
}
