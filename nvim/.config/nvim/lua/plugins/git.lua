local close_diffview = "<cmd>DiffviewClose<cr>"

-- 窄窗口下 diff2_horizontal 两栏太挤：按打开时的窗口宽度动态选布局，
-- 宽屏保持左右对比，窄屏切换上下分栏（可用 g<C-x> 在视图内手动循环切换）
local function apply_diffview_layout()
  local layout = vim.o.columns >= 160 and "diff2_horizontal" or "diff2_vertical"
  local config = require("diffview.config")
  config.get_config().view.default.layout = layout
  config.get_config().view.file_history.layout = layout
end

local function diffview_open(args)
  apply_diffview_layout()
  vim.cmd(("DiffviewOpen %s"):format(args or ""))
end

local function map_diffview_close(bufnr)
  for _, lhs in ipairs({ "q", "gq" }) do
    vim.keymap.set("n", lhs, close_diffview, {
      buffer = bufnr,
      desc = "Close Diff View",
      nowait = true,
      silent = true,
    })
  end
end

local function map_diffview_buffers(view)
  local tabpage = view and view.tabpage or 0

  if tabpage ~= 0 and not vim.api.nvim_tabpage_is_valid(tabpage) then
    return
  end

  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tabpage)) do
    local bufnr = vim.api.nvim_win_get_buf(win)
    local name = vim.api.nvim_buf_get_name(bufnr)

    if name:match("^diffview://") then
      map_diffview_close(bufnr)
    end
  end
end

return {
  {
    "sindrets/diffview.nvim",
    cmd = {
      "DiffviewOpen",
      "DiffviewClose",
      "DiffviewToggleFiles",
      "DiffviewFocusFiles",
      "DiffviewRefresh",
      "DiffviewFileHistory",
    },
    opts = {
      enhanced_diff_hl = true,
      hooks = {
        view_opened = map_diffview_buffers,
        view_post_layout = map_diffview_buffers,
      },
      view = {
        default = {
          layout = "diff2_horizontal",
          disable_diagnostics = true,
          winbar_info = true,
        },
        file_history = {
          layout = "diff2_horizontal",
          disable_diagnostics = true,
          winbar_info = true,
        },
      },
      file_panel = {
        listing_style = "tree",
        win_config = {
          position = "left",
          width = 28,
        },
      },
      keymaps = {
        view = {
          q = close_diffview,
          gq = close_diffview,
          ["<leader>e"] = "<cmd>DiffviewFocusFiles<cr>",
          ["<leader>b"] = "<cmd>DiffviewToggleFiles<cr>",
        },
        diff1 = {
          q = close_diffview,
          gq = close_diffview,
        },
        diff2 = {
          q = close_diffview,
          gq = close_diffview,
        },
        diff3 = {
          q = close_diffview,
          gq = close_diffview,
        },
        diff4 = {
          q = close_diffview,
          gq = close_diffview,
        },
        file_panel = {
          q = close_diffview,
          gq = close_diffview,
          ["<leader>e"] = "<cmd>DiffviewFocusFiles<cr>",
          ["<leader>b"] = "<cmd>DiffviewToggleFiles<cr>",
        },
        file_history_panel = {
          q = close_diffview,
          gq = close_diffview,
          ["<leader>e"] = "<cmd>DiffviewFocusFiles<cr>",
          ["<leader>b"] = "<cmd>DiffviewToggleFiles<cr>",
        },
      },
    },
    keys = {
      { "<leader>gd", function() diffview_open("") end, desc = "Diff View" },
      { "<leader>gD", function() diffview_open("-- %") end, desc = "Diff Current File" },
      { "<leader>gS", function() diffview_open("--staged") end, desc = "Diff Staged" },
      { "<leader>gH", function()
          apply_diffview_layout()
          vim.cmd("DiffviewFileHistory %")
        end, desc = "Diff File History" },
      { "<leader>gq", "<cmd>DiffviewClose<cr>", desc = "Close Diff View" },
    },
  },

  {
    "lewis6991/gitsigns.nvim",
    opts = {
      current_line_blame = true,
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = "eol",
        delay = 600,
        ignore_whitespace = false,
        virt_text_priority = 100,
      },
      current_line_blame_formatter = " <author>, <author_time:%R> - <summary>",
    },
  },
  {
    "gitsigns.nvim",
    opts = function()
      Snacks.toggle({
        name = "Git Blame Line",
        get = function()
          return require("gitsigns.config").config.current_line_blame
        end,
        set = function(state)
          require("gitsigns").toggle_current_line_blame(state)
        end,
      }):map("<leader>ub")
    end,
  },
}
