local group = vim.api.nvim_create_augroup("user_config", { clear = true })

-- Reload files changed outside Neovim when it is safe to do so.
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = group,
  command = "checktime",
})

-- Briefly highlight copied text.
vim.api.nvim_create_autocmd("TextYankPost", {
  group = group,
  callback = function()
    vim.highlight.on_yank({ timeout = 150 })
  end,
})
