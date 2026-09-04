return {
  {
    "echasnovski/mini.pick",
    version = false,
    config = function()
      require("mini.pick").setup()
    end,
    keys = {
      {
        "<leader>ff",
        function()
          MiniPick.builtin.files()
        end,
        desc = "Find files",
      },
      {
        "<leader>fg",
        function()
          MiniPick.builtin.grep_live()
        end,
        desc = "Find text",
      },
      {
        "<leader>fb",
        function()
          MiniPick.builtin.buffers()
        end,
        desc = "Find buffers",
      },
    },
  },
}
