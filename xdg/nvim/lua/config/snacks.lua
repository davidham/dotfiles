-- ~/.config/nvim/lua/plugins/snacks.lua
return {
  {
    "folke/snacks.nvim",
    config = function()
      local snacks = require("snacks")

      -- force config at plugin load time
      snacks.setup({
        picker = {
          hidden = true,      -- show dotfiles by default
          ignored = false,    -- show gitignored files as well (optional)
          sources = {
            files = {
              hidden = true,
              ignored = false,
            },
          },
        },
      })

      -- optional: keymap to toggle hidden files inside explorer
      vim.api.nvim_set_keymap(
        "n",
        "<leader>uh",
        "<cmd>lua require('snacks.explorer').toggle_hidden()<CR>",
        { noremap = true, silent = true }
      )
    end,
  },

  -- disable other file-explorer plugins that might take precedence (example)
  -- add this block if you have neo-tree or nvim-tree enabled and want to disable them
  -- { "nvim-neo-tree/neo-tree.nvim", enabled = false },
  -- { "kyazdani42/nvim-tree.lua", enabled = false },
}
