return {
  {
    "EdenEast/nightfox.nvim",
    name = "nightfox",
    priority = 1000,
    opts = {
      options = {
        dim_inactive = false,
        terminal_colors = true,
        transparent = false,
        styles = {
          comments = "italic",
          keywords = "bold",
        },
      },
    },
    config = function(_, opts)
      require("nightfox").setup(opts)
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "carbonfox",
    },
  },
}
