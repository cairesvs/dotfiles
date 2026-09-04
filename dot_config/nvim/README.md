# Minimal Neovim configuration

A small Lua configuration built on **lazy.nvim**. It uses only six plugins and deliberately avoids a file tree, statusline plugin, dashboard, tabline, theme, and other permanent UI elements. The built-in statusline is reduced to the filename and cursor position.

> This uses the lightweight lazy.nvim plugin manager rather than the full LazyVim distribution. Plugin files use the same lazy.nvim specification format, so extending it remains straightforward.

## Included

- Python LSP via Pyright
- JavaScript and TypeScript LSP via `typescript-language-server`
- Completion and signatures via blink.cmp
- Automatic language-server installation via Mason
- Lightweight file, text, and buffer search via mini.pick
- Diagnostics without inline virtual text to keep the editor clean
- The search, split, clipboard, and save/quit behavior from the previous Vim configuration

Language servers are downloaded on the first normal Neovim startup. Open `:Mason` to inspect them and `:checkhealth vim.lsp` to troubleshoot LSP setup.

## Add another language

Edit the `servers` table at the top of [`lua/plugins/lsp.lua`](lua/plugins/lsp.lua):

```lua
local servers = {
  pyright = {},
  ts_ls = {},
  lua_ls = {}, -- one new line
}
```

Restart Neovim. Mason installs the server and the native Neovim LSP client enables it. Server names and settings are documented under `:help lspconfig-all`.

Per-server settings fit in the same table:

```lua
lua_ls = {
  settings = {
    Lua = { diagnostics = { globals = { "vim" } } },
  },
},
```

## Main keys

- `<space>ff` — find files
- `<space>fg` — search text
- `<space>fb` — find buffers
- `gd` / `gD` — definition / declaration
- `gr` / `gi` — references / implementation
- `K` — hover documentation
- `<space>ca` — code action
- `<space>rn` — rename
- `<space>d` — show line diagnostics
- `[d` / `]d` — previous / next diagnostic
- `<space>lf` — format through LSP
- `<space>w`, `<space>q`, `<space>Q` — write, quit window, quit all
- `<space>v`, `<space>s` — vertical / horizontal split
- `<space>h` — clear search highlighting
- `<space>y`, `<space>p` — system clipboard copy / paste

Run `:Lazy` to manage plugins and `:Mason` to manage language servers.
