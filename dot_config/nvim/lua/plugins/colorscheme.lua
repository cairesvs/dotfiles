return {
  "sonph/onehalf",
  lazy = false,
  priority = 1000,
  config = function()
    -- Add the vim subdirectory to runtimepath
    vim.opt.rtp:append(vim.fn.stdpath("data") .. "/lazy/onehalf/vim")
    vim.cmd("colorscheme onehalfdark")
  end,
}
