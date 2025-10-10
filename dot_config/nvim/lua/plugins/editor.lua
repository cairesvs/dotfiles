return {
  -- open file in GitHub
  {
    "linrongbin16/gitlinker.nvim",
    cmd = "GitLink",
    keys = {
      { "<leader>gH", "<cmd>GitLink<cr>", mode = { "n", "v" }, desc = "Copy GitHub link" },
      { "<leader>gO", "<cmd>GitLink!<cr>", mode = { "n", "v" }, desc = "Open in GitHub" },
    },
    opts = {},
  },
}
