local map = vim.keymap.set

map("n", "<leader>q", "<cmd>quit<cr>", { desc = "Quit window" })
map("n", "<leader>Q", "<cmd>quitall<cr>", { desc = "Quit Neovim" })
map("n", "<leader>w", "<cmd>write<cr>", { desc = "Write file" })
map("n", "<leader>v", "<cmd>vsplit<cr>", { desc = "Split vertically" })
map("n", "<leader>s", "<cmd>split<cr>", { desc = "Split horizontally" })
map("n", "<leader>h", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })

-- System clipboard
map("v", "<leader>y", '"+y', { desc = "Copy to clipboard" })
map("n", "<leader>Y", '"+yg_', { desc = "Copy line to clipboard" })
map("n", "<leader>y", '"+y', { desc = "Copy to clipboard" })
map({ "n", "v" }, "<leader>p", '"+p', { desc = "Paste from clipboard after cursor" })
map({ "n", "v" }, "<leader>P", '"+P', { desc = "Paste from clipboard before cursor" })
