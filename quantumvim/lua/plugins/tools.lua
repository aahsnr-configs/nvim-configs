-- ~/.config/nvim/lua/plugins/tools.lua
return {
  {
    "folke/snacks.nvim",
    version = "*", -- Latest stable semver release
    priority = 1000,
    lazy = false,
    opts = {
      dashboard = {
        preset = {
          header = table.concat({
            "",
            " ██████╗ ██╗   ██╗ █████╗ ███╗   ██╗████████╗██╗   ██╗███╗   ███╗",
            "██╔═══██╗██║   ██║██╔══██╗████╗  ██║╚══██╔══╝██║   ██║████╗ ████║",
            "██║   ██║██║   ██║███████║██╔██╗ ██║   ██║   ██║   ██║██╔████╔██║",
            "██║▄▄ ██║██║   ██║██╔══██║██║╚██╗██║   ██║   ██║   ██║██║╚██╔╝██║",
            "╚██████╔╝╚██████╔╝██║  ██║██║ ╚████║   ██║   ╚██████╔╝██║ ╚═╝ ██║",
            " ╚════▀▀  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝   ╚═╝    ╚═════╝ ╚═╝     ╚═╝",
            "",
          }, "\n"),
          keys = {
            -- Row 1
            {
              icon = "",
              key = "f",
              desc = "Find File",
              action = function()
                Snacks.picker.files()
              end,
            },
            { icon = "", key = "n", desc = "New File", action = ":ene | startinsert" },
            -- Row 2
            {
              icon = "",
              key = "g",
              desc = "Find Text",
              action = function()
                Snacks.picker.grep()
              end,
            },
            {
              icon = "",
              key = "r",
              desc = "Recent Files",
              action = function()
                Snacks.picker.recent()
              end,
            },
            -- Row 3
            {
              icon = "",
              key = "c",
              desc = "Config",
              action = function()
                Snacks.dashboard.open_config()
              end,
            },
            {
              icon = "",
              key = "s",
              desc = "Restore Session",
              action = function()
                Snacks.session.restore()
              end,
            },
            -- Row 4
            { icon = "", key = "l", desc = "Lazy", action = ":Lazy" },
            { icon = "", key = "m", desc = "Mason", action = ":Mason" },
            -- Row 5
            {
              icon = "",
              key = "t",
              desc = "Terminal",
              action = function()
                Snacks.terminal()
              end,
            },
            { icon = "", key = "q", desc = "Quit", action = ":qa" },
          },
        },
      },
      terminal = { enabled = true },
      bigfile = { enabled = true },
      quickfile = { enabled = true },
      statuscolumn = { enabled = true },
      words = { enabled = true },
      notifier = { enabled = true, timeout = 3000, style = "compact" },
      indent = {
        enabled = true,
        indent = { char = "│" },
        scope = { enabled = false },
      },
      scope = { enabled = true },
      picker = { enabled = true },
      input = { enabled = true },

      scroll = {
        enabled = true,
        filter = function(buf)
          return vim.bo[buf].filetype ~= "markdown"
        end,
        animate = {
          -- Smoother scroll animation (was step=15, total=150)
          duration = { step = 20, total = 200 },
          easing = "linear",
        },
      },

      animate = {
        enabled = true,
        duration = 100,
        easing = "linear",
        fps = 60,
      },
    },
    keys = {
      {
        "<leader>lg",
        function()
          Snacks.lazygit()
        end,
        desc = "Lazygit",
      },
      {
        "<leader>un",
        function()
          Snacks.notifier.hide()
        end,
        desc = "Dismiss All Notifications",
      },
      {
        "<c-/>",
        function()
          Snacks.terminal()
        end,
        mode = { "n", "t" },
        desc = "Toggle Terminal",
      },
      {
        "<leader>n",
        function()
          Snacks.notifier.show_history()
        end,
        desc = "Notification History",
      },
      {
        "<leader>ff",
        function()
          Snacks.picker.files()
        end,
        desc = "Find Files",
      },
      {
        "<leader>fg",
        function()
          Snacks.picker.grep()
        end,
        desc = "Live Grep",
      },
      {
        "<leader>fb",
        function()
          Snacks.picker.buffers()
        end,
        desc = "Buffers",
      },
      {
        "<leader>fh",
        function()
          Snacks.picker.help()
        end,
        desc = "Help Tags",
      },
      {
        "<leader>fr",
        function()
          Snacks.picker.recent()
        end,
        desc = "Recent Files",
      },
    },
  },

  {
    "nvim-neo-tree/neo-tree.nvim",
    version = "3.*", -- Pin to v3.x stable (was branch = "v3.x")
    cmd = "Neotree",
    dependencies = {
      { "nvim-lua/plenary.nvim", version = "*" },
      { "nvim-tree/nvim-web-devicons", version = "*" },
      { "MunifTanjim/nui.nvim", version = "*" },
    },
    keys = { { "<leader>e", "<cmd>Neotree toggle filesystem left<cr>", desc = "Toggle Explorer" } },
    opts = {
      window = { width = 35 },
      filesystem = { filtered_items = { visible = true, hide_dotfiles = false, hide_gitignored = true } },
    },
  },

  {
    "stevearc/oil.nvim",
    version = "*", -- Latest stable semver release
    cmd = "Oil",
    keys = { { "-", "<cmd>Oil<cr>", desc = "Oil: Open parent directory" } },
    opts = { default_file_explorer = false },
  },

  {
    "folke/flash.nvim",
    version = "*", -- Latest stable semver release
    event = "VeryLazy",
    opts = {},
    keys = {
      {
        "s",
        mode = { "n", "x", "o" },
        function()
          require("flash").jump()
        end,
        desc = "Flash jump",
      },
      {
        "S",
        mode = { "n", "x", "o" },
        function()
          require("flash").treesitter()
        end,
        desc = "Flash treesitter",
      },
    },
  },
}
