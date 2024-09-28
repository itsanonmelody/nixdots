return {
  {
    "neovim/nvim-lspconfig",
    -- event = "LazyFile",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp"
    },
    config = function(_, opts)
      local capabilities = require'cmp_nvim_lsp'.default_capabilities()
      require'lspconfig'.bashls.setup {
        capabilities = capabilities,
      }
      require'lspconfig'.clangd.setup {
        capabilities = capabilities,
      }
      require'lspconfig'.cmake.setup {
        capabilities = capabilities,
      }
      require'lspconfig'.cssls.setup {
        capabilities = capabilities,
      }
      require'lspconfig'.eslint.setup {
        capabilities = capabilities,
      }
      require'lspconfig'.glsl_analyzer.setup {
        capabilities = capabilities,
      }
      require'lspconfig'.html.setup {
        capabilities = capabilities,
      }
      require'lspconfig'.jqls.setup {
        capabilities = capabilities,
      }
      require'lspconfig'.jsonls.setup {
        capabilities = capabilities,
      }
      require'lspconfig'.lua_ls.setup {
        capabilities = capabilities,
      }
      require'lspconfig'.marksman.setup {
        capabilities = capabilities,
      }
      require'lspconfig'.nil_ls.setup {
        capabilities = capabilities,
      }
      require'lspconfig'.rust_analyzer.setup {
        capabilities = capabilities,
      }
      require'lspconfig'.yamlls.setup {
        capabilities = capabilities,
      }
      require'lspconfig'.zls.setup {
        capabilities = capabilities,
      }
    end
  },
  { "hrsh7th/cmp-nvim-lsp" }
}
