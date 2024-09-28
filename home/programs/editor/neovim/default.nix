{ config, pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    extraLuaConfig = ''
      vim.g.mapleader = " "
      vim.g.maplocalleader = "\\"
      require("lazy").setup({
        spec = {
          { import = "plugins" }
        },
        performance = {
          reset_packpath = false,
          rtp = {
            reset = false,
          },
        },
        dev = {
          path = "${pkgs.vimUtils.packDir config.programs.neovim.finalPackage.passthru.packpathDirs}/pack/myNeovimPackages/start",
          patterns = {
            "andweeb",
            "folke",
            "hrsh7th",
            "JoosepAlviste",
            "L3MON4D3",
            "lewis6991",
            "lukas-reineke",
            "mfussenegger",
            "MunifTanjim",
            "neovim",
            "numToStr",
            "nvim-lua",
            "nvim-neo-tree",
            "nvim-neotest",
            "nvim-telescope",
            "nvim-tree",
            "nvim-treesitter",
            "rcarriga",
            "saadparwaiz1",
            "windwp",
          },
        },
        install = {
          missing = false,
        },
      })

      vim.cmd[[colorscheme tokyonight]]
      vim.cmd[[filetype plugin indent on]]

      vim.o.linebreak = true
      vim.o.breakindent = true
      vim.o.showbreak = "↪"
      vim.o.list = true
      vim.o.listchars = "tab:➡·,trail:·"
      vim.o.number = true
      vim.o.relativenumber = true

      vim.o.tabstop = 4
      vim.o.shiftwidth = 4
      vim.o.smarttab = true
      vim.o.softttabstop = 4 
      vim.o.shiftround = true
      vim.o.expandtab = true
      vim.o.autoindent = true
      vim.o.smartindent = false
    '';
    extraPackages = with pkgs;
      [
        clang-tools
        cmake-language-server
        fd
        gcc
        git
        glsl_analyzer
        jq-lsp
        lua-language-server
        marksman
        nil
        nodePackages.bash-language-server
        ripgrep
        rust-analyzer
        vscode-langservers-extracted
        yaml-language-server
        zls
      ];
    plugins = with pkgs.vimPlugins;
      [
        # Plugin management
        lazy-nvim

        # Treesitter
        (nvim-treesitter.withPlugins (p: with p;
          [
            asm
            bash
            c
            cmake
            commonlisp
            cpp
            css
            diff
            ebnf
            glsl
            html
            http
            hyprlang
            ini
            javascript
            jq
            json
            lua
            make
            markdown
            nasm
            nix
            printf
            regex
            rust
            scss
            strace
            toml
            udev
            yaml
            zig
          ]))

        # Auto completion
        nvim-cmp
        cmp-nvim-lsp
        cmp-buffer
        cmp-path
        luasnip
        cmp_luasnip

        # LSP
        nvim-lspconfig

        # Debugging
        nvim-dap
        nvim-dap-ui
        nvim-nio

        # Fuzzy find
        telescope-nvim

        # File system
        neo-tree-nvim

        # Key mapping
        which-key-nvim

        # Indent guides
        indent-blankline-nvim

        # Comments
        comment-nvim
        nvim-ts-context-commentstring

        # Autopairs
        nvim-autopairs
        nvim-ts-autotag

        # Git integration
        gitsigns-nvim
        
        # Discord RPC
        presence-nvim

        # Utility
        plenary-nvim

        # Theme
        tokyonight-nvim
      ];
  };

  xdg.configFile."nvim/lua" = {
    recursive = true;
    source = ./lua;
  };
}
