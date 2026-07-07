return {
  -- 1. Re-teach treesitter how to download and build the norg parsers automatically
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      local parser_config = require("nvim-treesitter.parsers").get_parser_configs()

      parser_config.norg = {
        install_info = {
          url = "https://github.com/nvim-neorg/tree-sitter-norg",
          files = { "src/parser.c", "src/scanner.cc" }, -- Tracks the C++ scanner
          branch = "main",
        },
      }

      parser_config.norg_meta = {
        install_info = {
          url = "https://github.com/nvim-neorg/tree-sitter-norg-meta",
          files = { "src/parser.c" },
          branch = "main",
        },
      }

      -- Automatically install them alongside your other languages
      if type(opts.ensure_installed) == "table" then
        table.insert(opts.ensure_installed, "norg")
        table.insert(opts.ensure_installed, "norg_meta")
      end
    end,
  },

  -- 2. Force Neorg onto the main branch to fetch the latest load-order patches
  {
    "nvim-neorg/neorg",
    -- By default, astrocommunity pins Neorg to stable versions ("*")
    -- Setting version to false pulls the tip of the main branch where treesitter bugs are addressed
    version = false,
    opts = {
      load = {
        ["core.defaults"] = {},
        ["core.integrations.treesitter"] = {
          config = {
            -- Let Neovim's native treesitter layer do the heavy lifting
            configure_parsers = false,
          },
        },
      },
    },
  },
}
