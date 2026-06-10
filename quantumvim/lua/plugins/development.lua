-- ~/.config/nvim/lua/plugins/development.lua
return {
  -- ==========================================================================
  -- 1. MASON PACKAGE MANAGEMENT & AUTOMATED TOOLING
  -- ==========================================================================
  {
    "mason-org/mason.nvim",
    version = "2.*", -- v2: Neovim ≥ 0.10; new event names; get_install_path() removed
    config = function(_, opts)
      require("mason").setup(opts)

      -- Replaces WhoIsSethDaniel/mason-tool-installer.nvim, which is BROKEN
      -- with Mason v2 (issue #79: lspconfig_to_mason is nil — no upstream fix).
      -- Reads formatters/linters from conform.nvim and nvim-lint at runtime
      -- and installs them via :MasonInstall.
      local function collect_tools()
        local seen, tools = {}, {}
        local function add(name)
          if name and not seen[name] then
            seen[name] = true
            tools[#tools + 1] = name
          end
        end
        local ok_c, conform = pcall(require, "conform")
        if ok_c and conform.formatters_by_ft then
          for _, list in pairs(conform.formatters_by_ft) do
            for _, fmt in ipairs(list) do
              add(fmt)
            end
          end
        end
        local ok_l, lint = pcall(require, "lint")
        if ok_l and lint.linters_by_ft then
          for _, list in pairs(lint.linters_by_ft) do
            for _, lnt in ipairs(list) do
              add(lnt)
            end
          end
        end
        return tools
      end

      vim.api.nvim_create_user_command("MasonToolsInstall", function()
        local tools = collect_tools()
        if #tools == 0 then
          vim.notify("MasonToolsInstall: no tools discovered", vim.log.levels.WARN)
          return
        end
        vim.cmd("MasonInstall " .. table.concat(tools, " "))
      end, { desc = "Install Mason tools used by conform.nvim and nvim-lint" })
    end,
    cmd = "Mason",
    opts = {
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    },
  },
  {
    "mason-org/mason-lspconfig.nvim",
    version = "2.*",
    dependencies = {
      { "mason-org/mason.nvim", version = "2.*" },
      { "neovim/nvim-lspconfig", version = "2.*" },
    },
    opts = {
      ensure_installed = {
        "lua_ls",
        "basedpyright",
        "ts_ls",
        "html",
        "cssls",
        "jsonls",
        "gopls",
        "rust_analyzer",
        "bashls",
        "marksman",
        "texlab",
      },
      automatic_enable = true,
    },
  },

  -- ==========================================================================
  -- 2. COMPLETION ENGINE MODULE (BLINK.CMP & VISUAL EXTENSIONS)
  -- ==========================================================================
  {
    "xzbdmw/colorful-menu.nvim",
    opts = {},
  },
  {
    "saghen/blink.cmp",
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = {
      { "rafamadriz/friendly-snippets", version = "*" },
      { "xzbdmw/colorful-menu.nvim", version = "*" },
      { "saghen/blink.compat", version = "*" },
      { "kdheepak/cmp-latex-symbols", version = "*" },
      { "moyiz/blink-emoji.nvim", version = "*" },
      { "mikavilpas/blink-ripgrep.nvim", version = "1.*" },
    },
    build = "cargo build --release",
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      enabled = function()
        return vim.bo.buftype ~= "prompt" and vim.b.completion ~= false
      end,

      cmdline = { enabled = true },

      keymap = {
        preset = "default",
        ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
        ["<C-b>"] = { "scroll_documentation_up", "fallback" },
        ["<C-f>"] = { "scroll_documentation_down", "fallback" },
        ["<C-k>"] = { "show_signature", "hide_signature", "fallback" },
        ["<C-u>"] = { "scroll_signature_up", "fallback" },
        ["<C-d>"] = { "scroll_signature_down", "fallback" },
      },

      appearance = {
        use_nvim_cmp_as_default = false,
        nerd_font_variant = "mono",
      },

      completion = {
        keyword = { range = "full" },
        accept = { auto_brackets = { enabled = false } },
        list = {
          selection = {
            preselect = function()
              return vim.bo.filetype ~= "markdown"
            end,
            auto_insert = true,
          },
        },
        ghost_text = { enabled = true },
        documentation = { auto_show = true, auto_show_delay_ms = 200 },

        menu = {
          border = "none",
          draw = {
            columns = {
              { "kind_icon" },
              { "label", gap = 1 },
            },
            components = {
              label = {
                text = function(ctx)
                  return require("colorful-menu").blink_components_text(ctx)
                end,
                highlight = function(ctx)
                  return require("colorful-menu").blink_components_highlight(ctx)
                end,
              },
            },
          },
        },
      },

      signature = { enabled = true },

      fuzzy = {
        implementation = "prefer_rust",
        prebuilt_binaries = { download = false },
        sorts = { "score", "sort_text", "kind", "label" },
      },

      snippets = { preset = "default" },

      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
        per_filetype = {
          lua = { "lsp", "path", "snippets", "buffer", "lazydev" },
          markdown = { "lsp", "path", "snippets", "buffer", "latex_symbols", "emoji", "ripgrep" },
          tex = { "lsp", "path", "snippets", "buffer", "latex_symbols", "emoji", "ripgrep" },
          plaintex = { "lsp", "path", "snippets", "buffer", "latex_symbols", "emoji", "ripgrep" },
        },
        providers = {
          lazydev = {
            name = "LazyDev",
            module = "lazydev.integrations.blink",
            score_offset = 100,
          },
          latex_symbols = {
            name = "latex_symbols",
            module = "blink.compat.source",
            score_offset = 2,
          },
          emoji = {
            name = "Emoji",
            module = "blink-emoji",
            score_offset = 1,
          },
          ripgrep = {
            name = "Ripgrep",
            module = "blink-ripgrep",
            score_offset = 0,
            -- blink.cmp provider-level throttle: never trigger below 4 chars
            min_keyword_length = 4,
            opts = {
              -- blink-ripgrep option: minimum prefix length to start searching
              prefix_min_len = 4,
              -- Prefer git grep in tracked repos (faster, respects .gitignore);
              -- fall back to ripgrep elsewhere. blink-ripgrep has no built-in
              -- backend switch, so we override get_command directly.
              get_command = function(_, prefix)
                local cwd = vim.fs.root(0, ".git") or vim.fn.getcwd()
                if vim.fs.root(0, ".git") then
                  return {
                    "git",
                    "grep",
                    "--only-matching",
                    "--no-color",
                    "-I",
                    "-i",
                    "--extended-regexp",
                    prefix .. "[\\w_-]+",
                    cwd,
                  }
                end
                return {
                  "rg",
                  "--no-config",
                  "--json",
                  "--word-regexp",
                  "--ignore-case",
                  "--max-filesize=1M",
                  "--",
                  prefix .. "[\\w_-]+",
                  cwd,
                }
              end,
            },
          },
        },
      },
    },
  },

  -- ==========================================================================
  -- 3. CORE LANGUAGE RUNTIMES & INTERFACES (LSP)
  -- ==========================================================================
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    version = "2.*",
    dependencies = {
      { "mason-org/mason.nvim", version = "2.*" },
      { "j-hui/fidget.nvim", version = "*" },
      { "mason-org/mason-lspconfig.nvim", version = "2.*" },
    },
    config = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
          local bufnr = ev.buf
          local map = function(keys, func, desc, extra_opts)
            extra_opts = extra_opts or {}
            local mode = extra_opts.mode or "n"
            extra_opts.mode = nil
            extra_opts.buffer = bufnr
            extra_opts.desc = "LSP: " .. desc
            vim.keymap.set(mode, keys, func, extra_opts)
          end

          -- Snacks picker mappings
          map("gd", function()
            Snacks.picker.lsp_definitions()
          end, "Go to Definition")
          map("gr", function()
            Snacks.picker.lsp_references()
          end, "Go to References")
          map("gI", function()
            Snacks.picker.lsp_implementations()
          end, "Go to Implementation")

          map("<leader>cr", vim.lsp.buf.rename, "Rename Symbol")
          map("<leader>ca", vim.lsp.buf.code_action, "Code Action", { mode = { "n", "v" } })
          map("K", vim.lsp.buf.hover, "Hover Documentation")
        end,
      })

      vim.lsp.config("*", {
        capabilities = require("blink.cmp").get_lsp_capabilities(),
      })

      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
            workspace = { checkThirdParty = false },
            telemetry = { enabled = false },
          },
        },
      })

      vim.lsp.config("basedpyright", {
        settings = {
          basedpyright = {
            analysis = {
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              diagnosticMode = "openFilesOnly",
              typeCheckingMode = "basic",
            },
          },
        },
      })

      vim.lsp.config("marksman", {
        filetypes = { "markdown", "md" },
      })

      vim.lsp.config("html", {
        filetypes = { "html", "xhtml" },
        init_options = { provideFormatter = true },
      })

      vim.lsp.config("bashls", {
        filetypes = { "sh", "bash" },
        settings = { bashIde = { globPattern = "*@(.sh|.inc|.bash|.command)" } },
      })

      vim.lsp.config("texlab", {
        settings = {
          texlab = {
            build = {
              executable = "latexmk",
              args = { "-pdf", "-interaction=nonstopmode", "-synctex=1", "%f" },
              onSave = true,
            },
            forwardSearch = {
              executable = "zathura",
              args = { "--synctex-forward", "%l:1:%c", "%p" },
            },
            chktex = { onOpenAndSave = true, onType = false },
            diagnosticsDelay = 300,
          },
        },
      })
    end,
  },
  {
    "folke/trouble.nvim",
    dependencies = { { "nvim-tree/nvim-web-devicons", version = "*" } },
    opts = {},
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics (Trouble)" },
      { "<leader>cs", "<cmd>Trouble symbols toggle<cr>", desc = "Symbols (Trouble)" },
      { "<leader>cl", "<cmd>Trouble lsp toggle<cr>", desc = "LSP (Trouble)" },
      {
        "<leader>ce",
        function()
          vim.diagnostic.open_float({ scope = "cursor", severity = vim.diagnostic.severity.ERROR })
        end,
        desc = "Diagnostics: Describe Error at Cursor",
      },
      {
        "<leader>xe",
        "<cmd>Trouble diagnostics toggle filter.severity=ERROR<cr>",
        desc = "Diagnostics: Toggle All Errors",
      },
      {
        "<leader>cw",
        function()
          vim.diagnostic.open_float({ scope = "cursor", severity = vim.diagnostic.severity.WARN })
        end,
        desc = "Diagnostics: Describe Warning at Cursor",
      },
      {
        "<leader>xw",
        "<cmd>Trouble diagnostics toggle filter.severity=WARN<cr>",
        desc = "Diagnostics: Toggle All Warnings",
      },
      {
        "<leader>xd",
        function()
          vim.diagnostic.enable(not vim.diagnostic.is_enabled())
        end,
        desc = "Diagnostics: Global Toggle On/Off",
      },
    },
  },

  -- ==========================================================================
  -- 4. WORKSPACE AUTOMATED FORMATTING LIFECYCLES (CONFORM)
  -- ==========================================================================
  {
    "stevearc/conform.nvim",
    event = "VeryLazy",
    keys = {
      {
        "<leader>cf",
        function()
          require("conform").format({ async = true })
        end,
        desc = "Format buffer",
      },
    },
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "ruff_fix", "ruff_format", "ruff_organize_imports" },
        markdown = { "prettierd" },
        html = { "prettierd" },
        css = { "prettierd" },
        scss = { "prettierd" },
        json = { "prettierd" },
        jsonc = { "prettierd" },
        yaml = { "prettierd" },
        javascript = { "prettierd" },
        typescript = { "prettierd" },
        javascriptreact = { "prettierd" },
        typescriptreact = { "prettierd" },
        go = { "gofumpt", "goimports" },
        rust = { "rustfmt" },
        bash = { "shfmt" },
        tex = { "latexindent" },
        plaintex = { "latexindent" },
      },
      format_on_save = function(_)
        if not vim.g.autoformat then
          return
        end
        return { timeout_ms = 1000, lsp_format = "fallback" }
      end,
    },
  },

  -- ==========================================================================
  -- 5. ASYNCHRONOUS WORKSPACE LINTING OPERATIONS (NVIM-LINT)
  -- ==========================================================================
  {
    "mfussenegger/nvim-lint",
    event = "VeryLazy",
    config = function()
      local lint = require("lint")

      lint.linters.selene = lint.linters.selene or {}
      lint.linters.selene.args = {
        "--display-style",
        "quiet",
        "--config",
        vim.fn.expand("~/.config/nvim/selene.toml"),
      }

      lint.linters_by_ft = {
        lua = { "selene" },
        python = { "ruff" },
        markdown = { "markdownlint-cli2" },
        yaml = { "yamllint" },
        json = { "jsonlint" },
        tex = { "chktex" },
        plaintex = { "chktex" },
      }

      vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },
}
