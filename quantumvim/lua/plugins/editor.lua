-- ~/.config/nvim/lua/plugins/editor.lua
return {
  -- ── Tree-sitter Framework ────────────────────────────────────────────────
  {
    "romus204/tree-sitter-manager.nvim",
    dependencies = {}, -- tree-sitter CLI must be installed system-wide
    config = function()
      require("tree-sitter-manager").setup({
        -- ensure_installed = {}, -- list of parsers to install at the start of a neovim session. If set to "all", install all parsers.
        auto_install = true,
        highlight = true,
        -- languages = {}, -- override or add new parser sources
      })
    end
  },

  -- ── TS-Autotag ────────────────────────────────────────────────────────────
  {
    "windwp/nvim-ts-autotag",
    version = "*", -- Latest stable semver release
    event = "BufReadPost",
    config = function()
      require("nvim-ts-autotag").setup({
        filetypes = {
          "html",
          "javascript",
          "typescript",
          "javascriptreact",
          "typescriptreact",
          "svelte",
          "vue",
          "xml",
          "markdown",
        },
      })
    end,
  },

  {
    "folke/todo-comments.nvim",
    optional = true,
    -- stylua: ignore
    keys = {
      { "<leader>st", function() Snacks.picker.todo_comments() end,                                          desc = "Todo" },
      { "<leader>sT", function() Snacks.picker.todo_comments({ keywords = { "TODO", "FIX", "FIXME" } }) end, desc = "Todo/Fix/Fixme" },
    },
  },

  {
    "folke/ts-comments.nvim",
    version = "*", -- Latest stable semver release
    event = "VeryLazy",
    opts = {},
  },

  -- ── mini.pairs ────────────────────────────────────────────────────────────
  {
    "nvim-mini/mini.pairs",
    event = "InsertEnter",
    config = function()
      require("mini.pairs").setup({
        modes = {
          insert = true,
          command = false,
          terminal = false,
        },
        mappings = {
          ["("] = { action = "open", pair = "()", neigh_pattern = "^[^\\]" },
          ["["] = { action = "open", pair = "[]", neigh_pattern = "^[^\\]" },
          ["{"] = { action = "open", pair = "{}", neigh_pattern = "^[^\\]" },
          [")"] = { action = "close", pair = "()", neigh_pattern = "^[^\\]" },
          ["]"] = { action = "close", pair = "[]", neigh_pattern = "^[^\\]" },
          ["}"] = { action = "close", pair = "{}", neigh_pattern = "^[^\\]" },
          ['"'] = {
            action = "closeopen",
            pair = '""',
            neigh_pattern = "^[^\\]",
            register = { cr = false },
          },
          ["'"] = {
            action = "closeopen",
            pair = "''",
            neigh_pattern = "^[^%a\\]",
            register = { cr = false },
          },
          ["`"] = {
            action = "closeopen",
            pair = "``",
            neigh_pattern = "^[^\\]",
            register = { cr = false },
          },
        },
      })
    end,
  },
}
