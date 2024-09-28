return {
  {
    "numToStr/Comment.nvim",
    dependencies = { "JoosepAlviste/nvim-ts-context-commentstring" },
    lazy = false,
    opts = {
      pre_hook = require'ts_context_commentstring.integrations.comment_nvim'.create_pre_hook(),
    },
    config = function(_, opts)
      vim.cmd[[runtime plugin/Comment.lua]]
      require'Comment'.setup(opts)
    end
  },
  { "JoosepAlviste/nvim-ts-context-commentstring" }
}
