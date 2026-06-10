-- ~/.config/nvim/lua/plugins/git.lua
return {
  {
    "lewis6991/gitsigns.nvim",
    version = "*", -- Latest stable semver release
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "▎" },
        topdelete = { text = "▎" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      },
      signs_staged = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "▎" },
        topdelete = { text = "▎" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      },
      signs_staged_enable = true,
      linehl = false,
      numhl = true,
      attach_to_untracked = true,
      watch_gitdir = { follow_files = true },
      on_attach = function(bufnr)
        local gs = require("gitsigns")
        local function map(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc, silent = true })
        end

        map("n", "<leader>hs", gs.stage_hunk, "Stage hunk")
        map("n", "<leader>hr", gs.reset_hunk, "Reset hunk")
        map("v", "<leader>hs", function()
          gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, "Stage hunk (visual)")
        map("v", "<leader>hr", function()
          gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, "Reset hunk (visual)")
        map("n", "<leader>hS", gs.stage_buffer, "Stage buffer")
        map("n", "<leader>hR", gs.reset_buffer, "Reset buffer")
        -- Undo_stage_hunk is deprecated but still functional (gitsigns#1180).
        map("n", "<leader>hu", gs.undo_stage_hunk, "Undo stage hunk")
        map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
        map("n", "<leader>hb", function()
          gs.blame_line({ full = true })
        end, "Blame line")
        map("n", "<leader>tb", gs.toggle_current_line_blame, "Toggle line blame")
        map("n", "<leader>hd", gs.diffthis, "Diff this")
        map("n", "<leader>hD", function()
          gs.diffthis("~")
        end, "Diff this ~")

        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "Select inside hunk")
      end,
    },
    config = function(_, opts)
      require("gitsigns").setup(opts)

      vim.schedule(function()
        local colors = _G.colors or {}
        if colors.green then
          vim.api.nvim_set_hl(0, "GitSignsAdd", { fg = colors.green })
          vim.api.nvim_set_hl(0, "GitSignsChange", { fg = colors.yellow })
          vim.api.nvim_set_hl(0, "GitSignsDelete", { fg = colors.red })
          vim.api.nvim_set_hl(0, "GitSignsTopdelete", { fg = colors.red })
          vim.api.nvim_set_hl(0, "GitSignsChangedelete", { fg = colors.yellow })
          vim.api.nvim_set_hl(0, "GitSignsUntracked", { fg = colors.green })

          vim.api.nvim_set_hl(0, "GitSignsAddNr", { fg = colors.green, bold = true })
          vim.api.nvim_set_hl(0, "GitSignsChangeNr", { fg = colors.yellow, bold = true })
          vim.api.nvim_set_hl(0, "GitSignsDeleteNr", { fg = colors.red, bold = true })
          vim.api.nvim_set_hl(0, "GitSignsTopdeleteNr", { fg = colors.red, bold = true })
          vim.api.nvim_set_hl(0, "GitSignsChangedeleteNr", { fg = colors.yellow, bold = true })
          vim.api.nvim_set_hl(0, "GitSignsUntrackedNr", { fg = colors.green, bold = true })

          vim.api.nvim_set_hl(0, "GitSignsAddLn", { bg = "#2d3f34" })
          vim.api.nvim_set_hl(0, "GitSignsChangeLn", { bg = "#413f30" })
          vim.api.nvim_set_hl(0, "GitSignsDeleteLn", { bg = "#43242a" })
          vim.api.nvim_set_hl(0, "GitSignsTopdeleteLn", { bg = "#43242a" })
          vim.api.nvim_set_hl(0, "GitSignsChangedeleteLn", { bg = "#413f30" })
          vim.api.nvim_set_hl(0, "GitSignsUntrackedLn", { bg = "#2d3f34" })
        end
      end)
    end,
  },

  {
    "tpope/vim-fugitive",
    version = "*", -- Latest stable semver release
    cmd = {
      "Git",
      "G",
      "Gdiffsplit",
      "Gread",
      "Gwrite",
      "Ggrep",
      "GMove",
      "GDelete",
      "GBrowse",
      "GRemove",
      "GRename",
      "Glgrep",
      "Gedit",
    },
    keys = { { "<leader>gs", "<cmd>Git<cr>", desc = "Git status" } },
  },
}
