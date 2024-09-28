return {
  {
    "nvim-treesitter/nvim-treesitter",
    version = false,
    -- event = { "LazyFile", "VeryLazy" },
    lazy = vim.fn.argc(-1) == 0,
    init = function(plugin)
      require'lazy.core.loader'.add_to_rtp(plugin)
      require'nvim-treesitter.query_predicates'
    end,
    opts = {
      auto_install = false,
      ensure_installed = {},
    }
  }
}
