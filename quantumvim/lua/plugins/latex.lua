-- ~/.config/nvim/lua/plugins/latex.lua
return {
  {
    "lervag/vimtex",
    version = "*", -- Latest stable semver release
    optional = true,
    config = function()
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("LatexSpell", { clear = true }),
        pattern = { "tex", "plaintex" },
        callback = function()
          vim.opt_local.spell = true
          vim.opt_local.spelllang = "en_us"
          -- Two-tier (project + global) spellfile via shared helper
          vim.opt_local.spellfile = require("core.spellfile").resolve()
        end,
      })
    end,
  },
}
