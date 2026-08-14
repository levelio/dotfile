local function move_key(keys, from, to)
  for _, key in ipairs(keys or {}) do
    if key[1] == from then
      key[1] = to
      table.insert(keys, { from, false, mode = key.mode })
      return
    end
  end
end

local function replace_key(keys, replacement)
  for index, key in ipairs(keys or {}) do
    if key[1] == replacement[1] then
      keys[index] = replacement
      return
    end
  end

  table.insert(keys, replacement)
end

local function references_key(lhs)
  return {
    lhs,
    function()
      Snacks.picker.lsp_references()
    end,
    desc = "References",
    nowait = true,
    has = "references",
  }
end

local function close_current_buffer()
  Snacks.bufdelete()
end

-- bufferline 没有内置按修改时间排序，自定义 sorter（供 <leader>bsm 使用）
local function sort_by_mtime(a, b)
  return (vim.fn.getftime(a.path) or 0) < (vim.fn.getftime(b.path) or 0)
end

local function move_which_key_group(opts, from, to, group)
  local moved = false
  opts.spec = opts.spec or {}

  for _, spec in ipairs(opts.spec) do
    for _, key in ipairs(spec) do
      if type(key) == "table" and key[1] == from and key.group == group then
        key[1] = to
        moved = true
      end
    end
  end

  if not moved then
    table.insert(opts.spec, {
      mode = { "n", "x" },
      { to, group = group },
    })
  end
end

return {
  {
    "folke/snacks.nvim",
    keys = {
      { "<leader>c", close_current_buffer, desc = "Close Current Buffer" },
      { "<leader>gd", false },
      { "<leader>gD", false },
      { "<leader>gS", false },
      -- buffer 快捷键对齐 AstroNvim（https://docs.astronvim.com/mappings#buffers）
      { "<leader>bb", function() Snacks.picker.buffers() end, desc = "Buffer Picker" },
      { "<leader>bd", function() Snacks.picker.buffers({ confirm = "bufdelete" }) end, desc = "Delete Buffer (Picker)" },
      { "<leader>b\\", function() Snacks.picker.buffers({ confirm = "split" }) end, desc = "Split Buffer Horizontal" },
      { "<leader>b|", function() Snacks.picker.buffers({ confirm = "vsplit" }) end, desc = "Split Buffer Vertical" },
      { "<leader>bp", "<cmd>bprevious<cr>", desc = "Previous Buffer" },
      { "<leader>bc", function() Snacks.bufdelete.other() end, desc = "Close Others" },
      { "<leader>bC", function() Snacks.bufdelete.all() end, desc = "Close All Buffers" },
    },
  },

  {
    "akinsho/bufferline.nvim",
    optional = true,
    keys = {
      -- 禁用 LazyVim 特有键：bp 占用了 AstroNvim 的 previous buffer；bP/bj AstroNvim 无此概念
      { "<leader>bp", false },
      { "<leader>bP", false },
      { "<leader>bj", false },
      -- AstroNvim 补充：移动与排序（bl/br 关左右两侧 LazyVim 默认已与 AstroNvim 一致，保留）
      { ">b", "<cmd>BufferLineMoveNext<cr>", desc = "Move Buffer Right" },
      { "<b", "<cmd>BufferLineMovePrev<cr>", desc = "Move Buffer Left" },
      { "<leader>bse", function() require("bufferline.commands").sort_by("extension") end, desc = "Sort by Extension" },
      { "<leader>bsi", function() require("bufferline.commands").sort_by("id") end, desc = "Sort by Buffer Number" },
      { "<leader>bsm", function() require("bufferline.commands").sort_by(sort_by_mtime) end, desc = "Sort by Last Modification" },
      { "<leader>bsp", function() require("bufferline.commands").sort_by("directory") end, desc = "Sort by Full Path" },
      { "<leader>bsr", function() require("bufferline.commands").sort_by("relative_directory") end, desc = "Sort by Relative Path" },
    },
  },

  {
    "folke/which-key.nvim",
    opts = function(_, opts)
      move_which_key_group(opts, "<leader>c", "<leader>l", "code")
      table.insert(opts.spec, {
        mode = { "n", "x" },
        { "<leader>c", desc = "Close Current Buffer" },
      })
    end,
  },

  {
    "folke/trouble.nvim",
    keys = {
      { "<leader>cs", false },
      { "<leader>cS", false },
      { "<leader>ls", "<cmd>Trouble symbols toggle<cr>", desc = "Symbols (Trouble)" },
      { "<leader>lS", "<cmd>Trouble lsp toggle<cr>", desc = "LSP references/definitions/... (Trouble)" },
    },
  },

  {
    "stevearc/conform.nvim",
    keys = {
      { "<leader>cF", false, mode = { "n", "x" } },
      {
        "<leader>lF",
        function()
          require("conform").format({ formatters = { "injected" }, timeout_ms = 3000 })
        end,
        mode = { "n", "x" },
        desc = "Format Injected Langs",
      },
    },
  },

  {
    "mason-org/mason.nvim",
    keys = {
      { "<leader>cm", false },
      { "<leader>lm", "<cmd>Mason<cr>", desc = "Mason" },
    },
  },

  {
    "linux-cultist/venv-selector.nvim",
    keys = {
      { "<leader>cv", false, ft = "python" },
      { "<leader>lv", "<cmd>VenvSelect<cr>", desc = "Select VirtualEnv", ft = "python" },
    },
  },

  {
    "iamcco/markdown-preview.nvim",
    keys = {
      { "<leader>cp", false, ft = "markdown" },
      { "<leader>lp", "<cmd>MarkdownPreviewToggle<cr>", desc = "Markdown Preview", ft = "markdown" },
    },
  },

  {
    "mrcjkb/rustaceanvim",
    optional = true,
    opts = function(_, opts)
      opts.server = opts.server or {}
      local on_attach = opts.server.on_attach

      opts.server.on_attach = function(client, bufnr)
        if on_attach then
          on_attach(client, bufnr)
        end

        pcall(vim.keymap.del, "n", "<leader>cR", { buffer = bufnr })
        vim.keymap.set("n", "<leader>lR", function()
          vim.cmd.RustLsp("codeAction")
        end, { desc = "Code Action", buffer = bufnr })
      end
    end,
  },

  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      local keys = opts.servers["*"].keys
      replace_key(keys, references_key("gD"))
      move_key(keys, "<leader>cl", "<leader>ll")
      move_key(keys, "<leader>ca", "<leader>la")
      move_key(keys, "<leader>cc", "<leader>lc")
      move_key(keys, "<leader>cC", "<leader>lC")
      move_key(keys, "<leader>cR", "<leader>lR")
      move_key(keys, "<leader>cr", "<leader>lr")
      move_key(keys, "<leader>cA", "<leader>lA")
      move_key(keys, "<leader>co", "<leader>lo")

      local vtsls = opts.servers.vtsls
      if type(vtsls) == "table" then
        vtsls.keys = vtsls.keys or {}
        replace_key(vtsls.keys, references_key("gD"))
        move_key(vtsls.keys, "<leader>cM", "<leader>lM")
        move_key(vtsls.keys, "<leader>cD", "<leader>lD")
        move_key(vtsls.keys, "<leader>cV", "<leader>lV")
      end
    end,
  },
}
