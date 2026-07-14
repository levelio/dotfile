local M = {}

local styles = { "carbonfox", "nightfox", "duskfox", "terafox", "nordfox" }

local function current_nightfox_style()
  local name = vim.g.colors_name or ""
  if vim.fn.index(styles, name) >= 0 then
    return name
  end

  return "carbonfox"
end

function M.cycle_nightfox()
  local current = current_nightfox_style()
  local index = vim.fn.index(styles, current)
  local next_style = styles[(index + 1) % #styles + 1]

  vim.cmd.colorscheme(next_style)
  vim.notify("Nightfox: " .. next_style, vim.log.levels.INFO, { title = "Theme" })
end

return M
