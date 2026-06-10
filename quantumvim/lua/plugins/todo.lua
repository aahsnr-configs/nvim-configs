-- ~/.config/nvim/lua/plugins/todo.lua
return {
  {
    "bngarren/checkmate.nvim",
    version = "*", -- Latest stable semver release
    ft = "markdown",
    dependencies = {},
    opts = function()
      local function set_highlights()
        local has_catppuccin, cp_palettes = pcall(require, "catppuccin.palettes")
        if not has_catppuccin then
          return
        end

        local c = cp_palettes.get_palette("mocha") or {}
        if next(c) == nil then
          return
        end

        local hl = function(name, opts)
          opts.default = true
          vim.api.nvim_set_hl(0, name, opts)
        end

        hl("CheckmateTodoUnchecked", { fg = c.overlay1 })
        hl("CheckmateTodoChecked", { fg = c.green, strikethrough = true })
        hl("CheckmateTodoInProgress", { fg = c.yellow, bold = true })
        hl("CheckmateTodoOnHold", { fg = c.peach })
        hl("CheckmateTodoCancelled", { fg = c.surface2, strikethrough = true })

        hl("CheckmateMetaStarted", { fg = c.sky })
        hl("CheckmateMetaDone", { fg = c.green })
        hl("CheckmateMetaDue", { fg = c.red })
        hl("CheckmateMetaPriority", { fg = c.mauve })
      end

      set_highlights()
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = set_highlights,
        group = vim.api.nvim_create_augroup("CheckmateHighlights", { clear = true }),
      })

      return {
        enabled = true,
        notify = true,
        files = { "*.md", "*.markdown" },

        todo_states = {
          unchecked = {
            marker = "[ ]",
            name = "TODO",
            style = { hl_group = "CheckmateTodoUnchecked" },
          },
          checked = {
            marker = "[x]",
            name = "DONE",
            style = { hl_group = "CheckmateTodoChecked" },
          },
          custom = {
            { marker = "[-]", name = "IN-PROGRESS", style = { hl_group = "CheckmateTodoInProgress" } },
            { marker = "[~]", name = "ON-HOLD", style = { hl_group = "CheckmateTodoOnHold" } },
            { marker = "[/]", name = "CANCELLED", style = { hl_group = "CheckmateTodoCancelled" } },
          },
        },

        metadata = {
          started = {
            key = "started",
            label = " started",
            hl_group = "CheckmateMetaStarted",
            on_state = { "IN-PROGRESS" },
            value = { type = "datetime", format = "%Y-%m-%d" },
          },
          done = {
            key = "done",
            label = " done",
            hl_group = "CheckmateMetaDone",
            on_state = { "DONE" },
            value = { type = "datetime", format = "%Y-%m-%d" },
          },
          due = {
            key = "due",
            label = " due",
            hl_group = "CheckmateMetaDue",
            value = { type = "datetime", format = "%Y-%m-%d" },
          },
          priority = {
            key = "priority",
            label = " priority",
            hl_group = "CheckmateMetaPriority",
            value = { type = "string" },
          },
        },

        keys = {
          ["<leader>Tt"] = {
            rhs = "<cmd>Checkmate toggle<CR>",
            desc = "Toggle todo state",
            modes = { "n", "v" },
          },
          ["<leader>Tc"] = {
            rhs = "<cmd>Checkmate check<CR>",
            desc = "Mark DONE",
            modes = { "n", "v" },
          },
          ["<leader>Tu"] = {
            rhs = "<cmd>Checkmate uncheck<CR>",
            desc = "Mark TODO (unchecked)",
            modes = { "n", "v" },
          },
          ["<leader>T="] = {
            rhs = "<cmd>Checkmate cycle_next<CR>",
            desc = "Cycle to next state",
            modes = { "n", "v" },
          },
          ["<leader>T-"] = {
            rhs = "<cmd>Checkmate cycle_previous<CR>",
            desc = "Cycle to previous state",
            modes = { "n", "v" },
          },
          ["<leader>Tn"] = {
            rhs = "<cmd>Checkmate create<CR>",
            desc = "New todo at same level",
            modes = { "n", "v" },
          },
          ["<leader>Td"] = { rhs = "<cmd>Checkmate add_metadata due<CR>", desc = "Add @due date", modes = "n" },
          ["<leader>Tp"] = { rhs = "<cmd>Checkmate add_metadata priority<CR>", desc = "Add @priority", modes = "n" },
          ["<leader>Ta"] = { rhs = "<cmd>Checkmate archive<CR>", desc = "Archive completed todos", modes = "n" },
          ["<leader>Ts"] = { rhs = "<cmd>Checkmate select_todo<CR>", desc = "Search todos (picker)", modes = "n" },
        },

        picker = { provider = "snacks" },

        archive = { heading = "## ✔ Archive", auto_fold = true },
        linter = { enabled = false },
      }
    end,
  },
}
