-- ~/.config/nvim/lua/plugins/ui.lua
return {
  {
    "folke/noice.nvim",
    version = "*", -- Latest stable semver release
    event = "VeryLazy",
    dependencies = {
      { "MunifTanjim/nui.nvim", version = "*" },
    },
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
        },
      },
      routes = {
        {
          filter = { event = "msg_show", kind = "", find = "written" },
          opts = { skip = true },
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        inc_rename = false,
        lsp_doc_border = true,
      },
    },
  },
}
