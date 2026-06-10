-- ~/.config/nvim/lua/core/spellfile.lua
--

local M = {}

--- Resolve the spellfile option for the current buffer.
--- @return string  spellfile value suitable for `vim.opt_local.spellfile`
function M.resolve()
  local global_spell = vim.fn.stdpath("config") .. "/spell/en.utf-8.add"
  local buf_name = vim.api.nvim_buf_get_name(0)
  if buf_name == "" then
    return global_spell
  end
  local dir = vim.fn.fnamemodify(buf_name, ":h")
  local local_spell = dir .. "/.en.utf-8.add"
  if vim.uv.fs_stat(local_spell) then
    return local_spell .. "," .. global_spell
  end
  return global_spell
end

return M
