return {
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
          files = {
            hidden = true,
          },
          grep = {
            hidden = true,
          },
          explorer = {
            hidden = true,
            ignored = true,
          },
        },
        icons = {
          files = {
            enabled = true,
          },
        },
      },
      terminal = {
        win = {
          position = "float",
          border = "rounded",
          width = 0.9,
          height = 0.9,
        },
      },
    },
  },
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = function()
      local colors = {
        bg = "#0b0f12",
        fg = "#d7dce2",
        muted = "#6f7782",
        surface = "#161c22",
        surface2 = "#1f2933",
        blue = "#5b8fb9",
        cyan = "#4fa79f",
        green = "#6f9b74",
        yellow = "#c7a45a",
        error = "#d16d73",
        magenta = "#9a83b8",
        orange = "#b8895c",
        black = "#0b0f12",
      }

      local mode_colors = {
        n = colors.blue,
        no = colors.blue,
        nov = colors.blue,
        noV = colors.blue,
        ["no\22"] = colors.blue,
        niI = colors.blue,
        niR = colors.blue,
        niV = colors.blue,
        nt = colors.blue,
        v = colors.magenta,
        vs = colors.magenta,
        V = colors.magenta,
        Vs = colors.magenta,
        ["\22"] = colors.magenta,
        ["\22s"] = colors.magenta,
        s = colors.orange,
        S = colors.orange,
        ["\19"] = colors.orange,
        i = colors.green,
        ic = colors.green,
        ix = colors.green,
        R = colors.orange,
        Rc = colors.orange,
        Rx = colors.orange,
        Rv = colors.orange,
        Rvc = colors.orange,
        Rvx = colors.orange,
        c = colors.yellow,
        cv = colors.yellow,
        ce = colors.yellow,
        r = colors.cyan,
        rm = colors.cyan,
        ["r?"] = colors.cyan,
        ["!"] = colors.orange,
        t = colors.green,
      }

      local function mode_color()
        return { fg = colors.black, bg = mode_colors[vim.fn.mode()] or colors.blue, gui = "bold" }
      end

      local function section(fg)
        return { fg = fg or colors.fg, bg = colors.bg }
      end

      local function has_clients()
        return #vim.lsp.get_clients({ bufnr = 0 }) > 0
      end

      local function lsp_clients()
        local clients = vim.lsp.get_clients({ bufnr = 0 })
        local names = {}

        for _, client in ipairs(clients) do
          if client.name ~= "copilot" then
            table.insert(names, client.name)
          end
        end

        if #names == 0 then
          return ""
        end

        return "LSP " .. table.concat(names, ",")
      end

      return {
        options = {
          theme = {
            normal = {
              a = { fg = colors.black, bg = colors.blue, gui = "bold" },
              b = { fg = colors.fg, bg = colors.bg },
              c = { fg = colors.fg, bg = colors.bg },
              x = { fg = colors.fg, bg = colors.bg },
              y = { fg = colors.fg, bg = colors.bg },
              z = { fg = colors.black, bg = colors.blue, gui = "bold" },
            },
            insert = { a = { fg = colors.black, bg = colors.green, gui = "bold" } },
            visual = { a = { fg = colors.black, bg = colors.magenta, gui = "bold" } },
            replace = { a = { fg = colors.black, bg = colors.orange, gui = "bold" } },
            command = { a = { fg = colors.black, bg = colors.yellow, gui = "bold" } },
            inactive = {
              a = { fg = colors.muted, bg = colors.bg },
              b = { fg = colors.muted, bg = colors.bg },
              c = { fg = colors.muted, bg = colors.bg },
            },
          },
          globalstatus = true,
          icons_enabled = true,
          component_separators = "",
          section_separators = { left = "", right = "" },
          disabled_filetypes = {
            statusline = { "dashboard", "snacks_dashboard", "alpha", "starter" },
          },
        },
        sections = {
          lualine_a = {
            {
              "mode",
              fmt = function(mode)
                return " " .. mode .. " "
              end,
              color = mode_color,
              separator = { right = "" },
              padding = { left = 0, right = 0 },
            },
          },
          lualine_b = {
            {
              "branch",
              icon = "",
              color = section(colors.cyan),
              padding = { left = 2, right = 1 },
            },
            {
              "diff",
              symbols = { added = " ", modified = " ", removed = " " },
              diff_color = {
                added = { fg = colors.green, bg = colors.bg },
                modified = { fg = colors.yellow, bg = colors.bg },
                removed = { fg = colors.orange, bg = colors.bg },
              },
            },
          },
          lualine_c = {
            {
              "filename",
              path = 1,
              symbols = {
                modified = " ●",
                readonly = " ",
                unnamed = "[No Name]",
                newfile = "[New]",
              },
              color = section(colors.fg),
            },
          },
          lualine_x = {
            {
              "diagnostics",
              sources = { "nvim_diagnostic" },
              symbols = { error = " ", warn = " ", info = " ", hint = " " },
              diagnostics_color = {
                error = { fg = colors.error, bg = colors.bg },
                warn = { fg = colors.yellow, bg = colors.bg },
                info = { fg = colors.cyan, bg = colors.bg },
                hint = { fg = colors.blue, bg = colors.bg },
              },
            },
            {
              lsp_clients,
              icon = "",
              cond = has_clients,
              color = section(colors.green),
            },
            {
              "filetype",
              colored = true,
              icon_only = false,
              color = section(colors.magenta),
            },
          },
          lualine_y = {
            {
              "progress",
              color = { fg = colors.yellow, bg = colors.surface2, gui = "bold" },
              separator = { left = "", right = "" },
              padding = { left = 1, right = 1 },
            },
          },
          lualine_z = {
            {
              "location",
              color = { fg = colors.black, bg = colors.blue, gui = "bold" },
              separator = { left = "" },
              padding = { left = 1, right = 1 },
            },
          },
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = {
            {
              "filename",
              path = 1,
              color = { fg = colors.muted, bg = colors.bg },
            },
          },
          lualine_x = {
            {
              "location",
              color = { fg = colors.muted, bg = colors.bg },
            },
          },
          lualine_y = {},
          lualine_z = {},
        },
        extensions = { "lazy", "mason", "trouble", "quickfix", "toggleterm" },
      }
    end,
  },
}
