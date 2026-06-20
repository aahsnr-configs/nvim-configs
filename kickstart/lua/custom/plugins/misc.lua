-- 1. Install and load the plugin (full GitHub URL required — no shorthand)
vim.pack.add {
  'https://github.com/HakonHarnes/img-clip.nvim',
}

-- 2. Configure the plugin (equivalent to lazy.nvim's `opts = {}`)
require('img-clip').setup {
  -- add options here
  -- or leave it empty to use the default settings
}

-- 3. Keymap (equivalent to lazy.nvim's `keys = { ... }`)
vim.keymap.set('n', '<leader>p', '<cmd>PasteImage<cr>', {
  desc = 'Paste image from system clipboard',
})
