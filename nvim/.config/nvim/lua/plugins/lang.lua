return {
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}

      vim.list_extend(opts.ensure_installed, {
        "css-lsp",
        "emmet-language-server",
        "eslint-lsp",
        "html-lsp",
        "prettier",
        "pyright",
        "ruff",
        "rust-analyzer",
        "tailwindcss-language-server",
        "vtsls",
      })

      opts.ensure_installed = LazyVim.dedup(opts.ensure_installed)
    end,
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        html = {},
        cssls = {
          settings = {
            css = {
              validate = true,
              lint = {
                unknownAtRules = "ignore",
              },
            },
            less = {
              validate = true,
              lint = {
                unknownAtRules = "ignore",
              },
            },
            scss = {
              validate = true,
              lint = {
                unknownAtRules = "ignore",
              },
            },
          },
        },
        emmet_language_server = {
          filetypes = {
            "css",
            "html",
            "javascriptreact",
            "less",
            "sass",
            "scss",
            "typescriptreact",
          },
        },
      },
      setup = {
        eslint = function()
          if vim.g.lazyvim_eslint_auto_format == false then
            return
          end

          LazyVim.format.register({
            name = "eslint: fix all",
            primary = false,
            priority = 210,
            format = function(buf)
              local client = vim.lsp.get_clients({ name = "eslint", bufnr = buf })[1]
              if not client then
                return
              end

              client:request_sync("workspace/executeCommand", {
                command = "eslint.applyAllFixes",
                arguments = {
                  {
                    uri = vim.uri_from_bufnr(buf),
                    version = vim.lsp.util.buf_versions[buf],
                  },
                },
              }, 3000, buf)
            end,
            sources = function(buf)
              return #vim.lsp.get_clients({ name = "eslint", bufnr = buf }) > 0 and { "eslint" } or {}
            end,
          })
        end,
      },
    },
  },

  {
    "stevearc/conform.nvim",
    optional = true,
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      opts.formatters_by_ft.sass = { "prettier" }
      -- antfu/eslint-config 自己就是 formatter（官方定位是脱离 Prettier 使用），
      -- 风格与 Prettier 相反（单引号/无分号）。JS/TS 家族若交给 prettier，
      -- 保存时会把 ESLint 的修复改回去；移除后 conform 会 fallback 到 eslint LSP 格式化。
      for _, ft in ipairs({
        "javascript",
        "javascriptreact",
        "javascript.jsx",
        "typescript",
        "typescriptreact",
        "typescript.tsx",
        "vue",
      }) do
        opts.formatters_by_ft[ft] = nil
      end
    end,
  },

  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = function(_, opts)
      opts.linters_by_ft = opts.linters_by_ft or {}
      opts.linters_by_ft.markdown = {}
      opts.linters_by_ft["markdown.mdx"] = {}
    end,
  },
}
