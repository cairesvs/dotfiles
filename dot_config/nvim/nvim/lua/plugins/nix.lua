-- Completely disable Mason management for Nix tools
return {
  {
    "williamboman/mason-lspconfig.nvim",
    opts = function(_, opts)
      -- Remove nil_ls from automatic installation
      opts.automatic_installation = false
      if opts.ensure_installed then
        for i = #opts.ensure_installed, 1, -1 do
          if opts.ensure_installed[i] == "nil_ls" then
            table.remove(opts.ensure_installed, i)
          end
        end
      end
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        nil_ls = {
          mason = false,
        },
      },
    },
  },
}
