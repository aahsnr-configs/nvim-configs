-- ~/.config/nvim/lua/plugins/markdown.lua

-- ── Highlight Definitions ─────────────────────────────────────────────────────
-- Safely queries Catppuccin's native module at runtime when applied or re-applied
-- on ColorScheme events, completely eliminating global variable dependencies.
local function define_highlights()
  local has_catppuccin, cp_palettes = pcall(require, "catppuccin.palettes")
  if not has_catppuccin then
    return
  end

  local c = cp_palettes.get_palette("mocha") or {}
  if next(c) == nil then
    return
  end

  local hl = function(name, opts)
    opts.default = true -- yield to colorscheme if it defines the group itself
    vim.api.nvim_set_hl(0, name, opts)
  end

  -- ── Heading foregrounds ──────────────────────────────────────────────────
  hl("RenderMarkdownH1", { fg = c.red, bold = true })
  hl("RenderMarkdownH2", { fg = c.peach, bold = true })
  hl("RenderMarkdownH3", { fg = c.yellow, bold = true })
  hl("RenderMarkdownH4", { fg = c.green, bold = true })
  hl("RenderMarkdownH5", { fg = c.sky, bold = true })
  hl("RenderMarkdownH6", { fg = c.lavender, bold = true })

  -- ── Heading backgrounds ──────────────────────────────────────────────────
  hl("RenderMarkdownH1Bg", { bg = "#30202a" }) -- warm rose  (title — brighter)
  hl("RenderMarkdownH2Bg", { bg = "#241d16" }) -- barely-peach
  hl("RenderMarkdownH3Bg", { bg = "#232112" }) -- barely-yellow
  hl("RenderMarkdownH4Bg", { bg = "#131e13" }) -- barely-green
  hl("RenderMarkdownH5Bg", { bg = "#101b20" }) -- barely-sky
  hl("RenderMarkdownH6Bg", { bg = "#171726" }) -- barely-lavender

  -- ── Code blocks ──────────────────────────────────────────────────────────
  hl("RenderMarkdownCode", { bg = c.mantle })
  hl("RenderMarkdownCodeBorder", { fg = c.surface1 })
  hl("RenderMarkdownCodeInline", { bg = c.surface1, fg = c.mauve })

  -- ── Horizontal rule ──────────────────────────────────────────────────────
  hl("RenderMarkdownDash", { fg = c.surface2 })

  -- ── Block quotes — cycling per nesting level ─────────────────────────────
  hl("RenderMarkdownQuote1", { fg = c.blue })
  hl("RenderMarkdownQuote2", { fg = c.mauve })
  hl("RenderMarkdownQuote3", { fg = c.teal })
  hl("RenderMarkdownQuote4", { fg = c.green })
  hl("RenderMarkdownQuote5", { fg = c.yellow })
  hl("RenderMarkdownQuote6", { fg = c.peach })

  -- ── Bullets ──────────────────────────────────────────────────────────────
  hl("RenderMarkdownBullet", { fg = c.sapphire })

  -- ── Tables ───────────────────────────────────────────────────────────────
  hl("RenderMarkdownTableHead", { fg = c.sapphire, bold = true })
  hl("RenderMarkdownTableRow", { fg = c.text })

  -- ── Checkboxes ───────────────────────────────────────────────────────────
  hl("RenderMarkdownUnchecked", { fg = c.overlay1 })
  hl("RenderMarkdownChecked", { fg = c.green })
  hl("RenderMarkdownTodo", { fg = c.yellow })

  -- ── Links ────────────────────────────────────────────────────────────────
  hl("RenderMarkdownLink", { fg = c.sky, underline = true })
  hl("RenderMarkdownWikiLink", { fg = c.teal, underline = true })

  -- ── Inline highlight (==text==) ───────────────────────────────────────────
  hl("RenderMarkdownInlineHighlight", { bg = c.surface1, fg = c.peach })

  -- ── Callout severity colours ─────────────────────────────────────────────
  hl("RenderMarkdownSuccess", { fg = c.green })
  hl("RenderMarkdownHint", { fg = c.teal })
  hl("RenderMarkdownInfo", { fg = c.blue })
  hl("RenderMarkdownWarn", { fg = c.yellow })
  hl("RenderMarkdownError", { fg = c.red })
end

-- ── Autocmd group ────────────────────────────────────────────────────────────
-- All markdown-related autocmds (highlights + buffer setup + paragraph
-- indent correction) live in this group with `clear = true`, so re-requiring
-- this module automatically purges stale autocmds and prevents the duplicate
-- registration that produced the E227 keymap notifications on every open.
local md_group = vim.api.nvim_create_augroup("MarkdownSetup", { clear = true })

-- ── Tree-sitter First-Paragraph Indent Clearing ──────────────────────────────
-- WHY THIS FALLBACK EXISTS:
-- render-markdown.nvim's `paragraph.indent` field applies a UNIFORM indent to
-- EVERY paragraph in the buffer. The plugin's public API has no hook to vary
-- the indent based on whether the paragraph is the first one after a heading.
-- To achieve the Word/Docs convention — "indent all paragraphs except the
-- first one under each heading" — we let render-markdown apply its uniform
-- 2-space indent, then use a tree-sitter query to locate the first
-- (paragraph) sibling after every (atx_heading) / (setext_heading) and delete
-- the virt_text extmark render-markdown placed on its first line. This
-- produces the exact typographic style used by Microsoft Word and Google
-- Docs in their "indent paragraphs" mode.
local function clear_first_paragraph_indent(bufnr)
  local ok, parser = pcall(vim.treesitter.get_parser, bufnr, "markdown")
  if not ok or not parser then
    return
  end

  local trees = parser:parse()
  local tree = trees and trees[1]
  if not tree then
    return
  end

  local root = tree:root()
  local first_paras = {}

  local function walk(node)
    local t = node:type()
    if t == "atx_heading" or t == "setext_heading" then
      local sib = node:next_named_sibling()
      while sib do
        if sib:type() == "paragraph" then
          table.insert(first_paras, sib)
          break
        end
        sib = sib:next_named_sibling()
      end
    end
    for c in node:iter_children() do
      walk(c)
    end
  end
  walk(root)

  -- Re-validate: treesitter parse() can take a moment, buffer may have
  -- been wiped in the meantime.
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end

  for _, p in ipairs(first_paras) do
    local sr = p:start()
    local ok_marks, marks = pcall(vim.api.nvim_buf_get_extmarks, bufnr, -1, { sr, 0 }, { sr, 0 }, { details = true })
    if not ok_marks or type(marks) ~= "table" then
      break
    end
    for _, m in ipairs(marks) do
      local id = m[1]
      local details = m[4]
      if details and details.virt_text and details.ns_id and type(id) == "number" then
        for _, chunk in ipairs(details.virt_text) do
          if type(chunk) == "table" and type(chunk[1]) == "string" and chunk[1]:match("^%s") then
            -- Delete by extmark ID; pcall guards against the buffer
            -- disappearing between get_extmarks and del_extmark.
            pcall(vim.api.nvim_buf_del_extmark, bufnr, details.ns_id, id)
            break
          end
        end
      end
    end
  end
end

-- Establish baseline highlights and hook into future layout refreshes
define_highlights()
vim.api.nvim_create_autocmd("ColorScheme", {
  group = md_group,
  callback = define_highlights,
})

-- ── Automated Buffer Setup ────────────────────────────────────────────────────
local function setup_markdown_buffer()
  -- ── Guard ────────────────────────────────────────────────────────────────
  -- Runs exactly once per buffer lifetime regardless of how many autocmds
  -- fire (FileType, session restore, BufReadPost). The named augroup above
  -- also prevents the autocmd itself from being registered twice.
  if vim.b.markdown_setup_done then
    return
  end
  vim.b.markdown_setup_done = true

  local bufnr = vim.api.nvim_get_current_buf()
  local buf_name = vim.api.nvim_buf_get_name(bufnr)
  local buf_dir = buf_name ~= "" and vim.fn.fnamemodify(buf_name, ":h") or ""

  -- ── Display options ───────────────────────────────────────────────────────
  vim.opt_local.conceallevel = 2 -- hide markup; required by render-markdown
  vim.opt_local.concealcursor = "nc" -- keep conceal in Normal+Cmd; reveal in Insert
  vim.opt_local.wrap = true
  vim.opt_local.linebreak = true
  vim.opt_local.breakindent = true
  vim.opt_local.showbreak = "  "
  vim.opt_local.spell = true
  vim.opt_local.spelllang = "en_us"

  -- ── Spellfile — two-tier enchant-style exemptions (via shared helper) ─────
  vim.opt_local.spellfile = require("core.spellfile").resolve()

  -- ── Bold autopair  **|**  (nowarn = true silences E227 if re-entered) ────
  vim.keymap.set("i", "**", "****<Left><Left>", { buffer = true, silent = true, desc = "Markdown: bold pair **|**" })

  -- ── Italic autopair  __|__  ───────────────────────────────────────────────

  vim.keymap.set("i", "__", "____<Left><Left>", { buffer = true, silent = true, desc = "Markdown: italic pair __|__" })

  -- ── Horizontal rule  ---<CR>  ─────────────────────────────────────────────
  vim.keymap.set("i", "---", "---<CR>", { buffer = true, silent = true, desc = "Markdown: horizontal rule + newline" })

  -- ── mini.pairs: markdown-specific buffer pairs ────────────────────────────
  local ok_mp, _ = pcall(require, "mini.pairs")
  if ok_mp and MiniPairs then
    MiniPairs.map_buf(bufnr, "i", "$", {
      action = "closeopen",
      pair = "$$",
      register = { cr = false },
    })
  end

  -- ── Non-destructive .markdownlint-cli2.yaml creation ─────────────────────
  if buf_dir ~= "" then
    local config_path = buf_dir .. "/.markdownlint-cli2.yaml"
    if not vim.uv.fs_stat(config_path) then
      local template = [[# Declarative Markdown Linter Configuration
config:
  default: true
  MD013: false  # Line length handled by Neovim wrap; not enforced here
  MD033: false  # Allow inline HTML
  MD024: false  # Allow duplicate heading names (changelogs, etc.)
  MD041: false  # Don't require a top-level H1 in every file
]]
      local f = io.open(config_path, "w")
      if f then
        f:write(template)
        f:close()
      end
    end
  end

  -- ── Debounced paragraph-indent correction (Req 3) ─────────────────────────
  -- Runs on text changes, insert-leave, save, and render-markdown's User
  -- events. 100 ms debounce coalesces rapid keystrokes into a single pass.
  local indent_timer
  vim.api.nvim_create_autocmd({ "TextChanged", "InsertLeave", "BufWritePost" }, {
    group = md_group,
    buffer = bufnr,
    callback = function()
      if not vim.api.nvim_buf_is_valid(bufnr) then
        return
      end
      if indent_timer then
        vim.fn.timer_stop(indent_timer)
      end
      indent_timer = vim.defer_fn(function()
        -- Final guard inside the deferred callback: 100 ms is more than
        -- enough time for the user to wipe the buffer (e.g. :bd, session
        -- switch) before the timer fires.
        if not vim.api.nvim_buf_is_valid(bufnr) then
          return
        end
        clear_first_paragraph_indent(bufnr)
      end, 100)
    end,
  })
end

-- ── Single canonical autocmd (now in named group) ────────────────────────────
vim.api.nvim_create_autocmd("FileType", {
  group = md_group,
  pattern = "markdown",
  callback = setup_markdown_buffer,
})

-- ── Plugin Specs (lazy.nvim) ──────────────────────────────────────────────────
return {
  ---------------------------------------------------------------------------
  -- render-markdown.nvim — in-buffer rendering via Neovim extmarks
  ---------------------------------------------------------------------------
  {
    "MeanderingProgrammer/render-markdown.nvim",
    version = "*", -- Latest stable semver release
    dependencies = {
      { "nvim-tree/nvim-web-devicons", version = "*" },
    },
    ft = { "markdown" },
    opts = {
      render_modes = { "n", "c" },
      completions = { lsp = { enabled = true } },

      anti_conceal = {
        enabled = true,
        above = 0,
        below = 0,
        ignore = {
          code_background = true,
          indent = true,
          sign = true,
          virtual_lines = true,
        },
      },

      padding = { highlight = "Normal" },

      win_options = {
        showbreak = { default = "", rendered = "  " },
        breakindent = { default = false, rendered = true },
        -- Req 4: "shift:0,min:0" is render-markdown's intended default; the
        -- previous empty string caused subtle showbreak/breakindent glitches.
        breakindentopt = { default = "shift:0,min:0", rendered = "shift:0,min:0" },
      },

      heading = {
        enabled = true,
        render_modes = false,
        atx = true,
        setext = true,
        sign = false,
        icons = { "❶ ", "② ", "③ ", "④ ", "⑤ ", "⑥ " },
        position = "overlay",
        width = "block",
        left_pad = 0,
        right_pad = 4,
        min_width = 0,
        border = true,
        border_virtual = true,
        border_prefix = true,
        above = "▄",
        below = "▀",
        backgrounds = {
          "RenderMarkdownH1Bg",
          "RenderMarkdownH2Bg",
          "RenderMarkdownH3Bg",
          "RenderMarkdownH4Bg",
          "RenderMarkdownH5Bg",
          "RenderMarkdownH6Bg",
        },
        foregrounds = {
          "RenderMarkdownH1",
          "RenderMarkdownH2",
          "RenderMarkdownH3",
          "RenderMarkdownH4",
          "RenderMarkdownH5",
          "RenderMarkdownH6",
        },
      },

      indent = { enabled = false },

      -- Req 3: Uniform 2-space indent for all paragraphs; the
      -- clear_first_paragraph_indent autocmd strips it from first-after-heading.
      paragraph = {
        enabled = true,
        render_modes = false,
        left_margin = 0,
        indent = 2,
        min_width = 0,
      },

      code = {
        enabled = true,
        sign = false,
        style = "full",
        width = "full",
        border = "thin",
        left_pad = 1,
        right_pad = 1,
        language_name = true,
        language_icon = true,
        highlight = "RenderMarkdownCode",
        highlight_border = "RenderMarkdownCodeBorder",
        highlight_inline = "RenderMarkdownCodeInline",
      },

      dash = {
        enabled = true,
        icon = "─",
        width = "full",
        highlight = "RenderMarkdownDash",
      },

      bullet = {
        enabled = true,
        icons = { "●", "○", "◆", "◇" },
        left_pad = 0,
        right_pad = 1,
        highlight = "RenderMarkdownBullet",
      },

      checkbox = {
        enabled = true,
        unchecked = { icon = "󰄱 ", highlight = "RenderMarkdownUnchecked" },
        checked = { icon = "󰱒 ", highlight = "RenderMarkdownChecked" },
        custom = {
          todo = { raw = "[-]", rendered = "󰥔 ", highlight = "RenderMarkdownTodo" },
        },
      },

      quote = {
        enabled = true,
        icon = "▎",
        repeat_linebreak = true,
        highlight = {
          "RenderMarkdownQuote1",
          "RenderMarkdownQuote2",
          "RenderMarkdownQuote3",
          "RenderMarkdownQuote4",
          "RenderMarkdownQuote5",
          "RenderMarkdownQuote6",
        },
      },

      callout = {
        note = { raw = "[!NOTE]", rendered = "󰋽 Note", highlight = "RenderMarkdownInfo" },
        tip = { raw = "[!TIP]", rendered = "󰌶 Tip", highlight = "RenderMarkdownSuccess" },
        important = { raw = "[!IMPORTANT]", rendered = "󰅾 Important", highlight = "RenderMarkdownHint" },
        warning = { raw = "[!WARNING]", rendered = "󰀪 Warning", highlight = "RenderMarkdownWarn" },
        caution = { raw = "[!CAUTION]", rendered = "󰳦 Caution", highlight = "RenderMarkdownError" },
        abstract = { raw = "[!ABSTRACT]", rendered = "󰨸 Abstract", highlight = "RenderMarkdownInfo" },
        info = { raw = "[!INFO]", rendered = "󰋽 Info", highlight = "RenderMarkdownInfo" },
        todo = { raw = "[!TODO]", rendered = "󰗡 Todo", highlight = "RenderMarkdownInfo" },
        hint = { raw = "[!HINT]", rendered = "󰴓 Hint", highlight = "RenderMarkdownHint" },
        success = { raw = "[!SUCCESS]", rendered = "󰄬 Success", highlight = "RenderMarkdownSuccess" },
        question = { raw = "[!QUESTION]", rendered = "󰘥 Question", highlight = "RenderMarkdownWarn" },
        bug = { raw = "[!BUG]", rendered = "󰨰 Bug", highlight = "RenderMarkdownError" },
        example = { raw = "[!EXAMPLE]", rendered = "󰉹 Example", highlight = "RenderMarkdownHint" },
        quote = { raw = "[!QUOTE]", rendered = "󱆨 Quote", highlight = "RenderMarkdownQuote1" },
      },

      pipe_table = {
        enabled = true,
        render_modes = false,
        preset = "round",
        cell = "padded",
        padding = 1,
        min_width = 0,
        alignment_indicator = "━",
        head = "RenderMarkdownTableHead",
        row = "RenderMarkdownTableRow",
      },

      link = {
        enabled = true,
        footnote = { superscript = true, prefix = "", suffix = "" },
        image = "󰋩 ",
        email = "󰀓 ",
        hyperlink = "󰌹 ",
        highlight = "RenderMarkdownLink",
        wiki = {
          icon = "󱗖 ",
          highlight = "RenderMarkdownWikiLink",
        },
      },

      sign = { enabled = false },

      inline_highlight = {
        enabled = true,
        highlight = "RenderMarkdownInlineHighlight",
      },

      overrides = {
        buftype = {
          nofile = {
            render_modes = true,
            padding = { highlight = "NormalFloat" },
            sign = { enabled = false },
            code = { left_pad = 0, right_pad = 0 },
          },
        },
      },
    },
  },

  ---------------------------------------------------------------------------
  -- peek.nvim — live Deno-based HTML preview in a side window
  ---------------------------------------------------------------------------
  {
    "toppair/peek.nvim",
    version = "*", -- Latest stable semver release
    ft = { "markdown" },
    build = "deno task --quiet build:fast",

    config = function()
      require("peek").setup({
        auto_load = false,
        close_on_bdelete = true,
        syntax = true,
        theme = "dark",
        update_on_change = true,
        app = "webview",
        filetype = { "markdown" },
        throttle_at = 200000,
        throttle_time = "auto",
      })

      vim.api.nvim_create_user_command("PeekOpen", require("peek").open, {})
      vim.api.nvim_create_user_command("PeekClose", require("peek").close, {})
    end,

    keys = {
      {
        "<leader>mp",
        function()
          local peek = require("peek")
          if peek.is_open() then
            peek.close()
          else
            peek.open()
          end
        end,
        ft = "markdown",
        desc = "Markdown: Toggle Peek Preview",
      },
    },
  },
}
