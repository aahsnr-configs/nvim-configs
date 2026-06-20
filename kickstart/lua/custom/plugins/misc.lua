vim.pack.add { 'https://github.com/HakonHarnes/img-clip.nvim' }

require('img-clip').setup {
  -- add options here
  -- or leave it empty to use the default settings
}

vim.keymap.set('n', '<leader>p', '<cmd>PasteImage<cr>', {
  desc = 'Paste image from system clipboard',
})

-------
-- This vim.pack.add() call should come FIRST in your init.lua
-- to replicate priority = 1000 (early startup loading)
vim.pack.add { 'https://github.com/folke/snacks.nvim' }

-- Configure the plugin (equivalent to opts = { ... })
-- Called immediately after add() since lazy = false means eager loading
require('snacks').setup {
  -- your configuration comes here
  -- or leave it empty to use the default settings
  -- refer to the configuration section below
  bigfile = { enabled = true },
  dashboard = { enabled = true },
  indent = { enabled = true },
  input = { enabled = true },
  notifier = { enabled = true },
  quickfile = { enabled = true },
  image = { enabled = true },
  scope = { enabled = true },
  scroll = { enabled = true },
  lazygit = { enabled = true },
  terminal = { enabled = true },
  statuscolumn = { enabled = true },
  words = { enabled = true },
}
