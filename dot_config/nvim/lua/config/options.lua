local opt = vim.opt

-- Search
opt.hlsearch = true
opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true

-- Files and history
opt.history = 700
opt.autoread = true
opt.backup = false
opt.writebackup = false
opt.swapfile = false
opt.undofile = true

-- Indentation
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.expandtab = true
opt.smartindent = true

-- Minimal UI: only a compact filename and cursor position remain.
opt.number = false
opt.relativenumber = false
opt.signcolumn = "no"
opt.laststatus = 2
opt.statusline = "%#MinimalStatus# %t %m%r %*%=%#MinimalStatus# %l,%c %*"
opt.ruler = false
opt.showmode = false
opt.showcmd = false
opt.cmdheight = 0
opt.showtabline = 0
opt.fillchars:append({ eob = " " })
opt.winminheight = 0
opt.termguicolors = true

local function set_minimal_status_highlights()
  vim.api.nvim_set_hl(0, "StatusLine", { bg = "NONE" })
  vim.api.nvim_set_hl(0, "StatusLineNC", { bg = "NONE" })
  vim.api.nvim_set_hl(0, "MinimalStatus", { reverse = true })
end

set_minimal_status_highlights()
vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("minimal_status_highlights", { clear = true }),
  callback = set_minimal_status_highlights,
})

-- Editing behavior
opt.splitbelow = true
opt.splitright = true
opt.updatetime = 250
opt.timeoutlen = 400
