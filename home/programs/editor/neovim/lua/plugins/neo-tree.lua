return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.*",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim"
    },
    keys = {
      {
        "<leader>nt",
        "<cmd>Neotree toggle<cr>",
        desc = "Neotree toggle"
      },
      {
        "<leader>nf",
        "<cmd>Neotree focus<cr>",
        desc = "Neotree focus"
      }
    }
  },
  { "nvim-lua/plenary.nvim" },
  { "nvim-tree/nvim-web-devicons" },
  { "MunifTanjim/nui.nvim" }
}
