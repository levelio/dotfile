-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
for _, key in ipairs({ "<D-s>", "<C-s>" }) do
  vim.keymap.set("n", key, "<cmd>update<cr>", { desc = "Save File" })
  vim.keymap.set("i", key, "<Esc><cmd>update<cr>a", { desc = "Save File" })
  vim.keymap.set("v", key, "<Esc><cmd>update<cr>gv", { desc = "Save File" })
  vim.keymap.set("c", key, "<C-c><cmd>update<cr>", { desc = "Save File" })
end
vim.keymap.set("n", "<leader>uT", function()
  require("config.theme").cycle_nightfox()
end, { desc = "Cycle Nightfox Theme" })
vim.keymap.set("i", "kj", "<Esc>", { desc = "Exit Insert Mode" })
for _, key in ipairs({ "<C-/>", "<C-_>" }) do
  vim.keymap.set({ "n", "t" }, key, function()
    Snacks.terminal()
  end, { desc = "Terminal (cwd)" })
end
pcall(vim.keymap.del, "n", "<leader>cd")
pcall(vim.keymap.del, { "n", "x" }, "<leader>cf")
vim.keymap.set("n", "<leader>ld", vim.diagnostic.open_float, { desc = "Line Diagnostics" })
vim.keymap.set({ "n", "x" }, "<leader>lf", function()
  LazyVim.format({ force = true })
end, { desc = "Format" })
vim.keymap.set("n", "<leader>lE", LazyVim.lsp.action["source.fixAll.eslint"], { desc = "ESLint Fix All" })

if vim.g.neovide then
  vim.keymap.set("n", "<D-v>", '"+p', { desc = "Paste Clipboard" })
  vim.keymap.set({ "i", "c" }, "<D-v>", "<C-r>+", { desc = "Paste Clipboard" })
  vim.keymap.set({ "v", "s" }, "<D-v>", '"+P', { desc = "Paste Clipboard" })

  local function neovide_font_size()
    return tonumber(vim.o.guifont:match(":h(%d+)")) or 16
  end

  local function set_neovide_font_size(size)
    vim.o.guifont = ("JetBrainsMono Nerd Font Mono,Noto Sans CJK SC:h%d"):format(size)
  end

  vim.keymap.set({ "n", "i", "v", "c" }, "<D-=>", function()
    set_neovide_font_size(neovide_font_size() + 1)
  end, { desc = "Increase Font Size" })
  vim.keymap.set({ "n", "i", "v", "c" }, "<D-->", function()
    set_neovide_font_size(math.max(8, neovide_font_size() - 1))
  end, { desc = "Decrease Font Size" })
  vim.keymap.set({ "n", "i", "v", "c" }, "<D-0>", function()
    set_neovide_font_size(16)
  end, { desc = "Reset Font Size" })
end
