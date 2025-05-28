return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "mattn/efm-langserver",
    { "antosha417/nvim-lsp-file-operations", config = true },
    { "folke/neodev.nvim",                   opts = {} },
  },
  config = function()
    -- import lspconfig plugin
    local lspconfig = require("lspconfig")

    -- import cmp-nvim-lsp plugin
    local cmp_nvim_lsp = require("cmp_nvim_lsp")

    local keymap = vim.keymap -- for conciseness

    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("UserLspConfig", {}),
      callback = function(ev)
        -- Buffer local mappings.
        -- See `:help vim.lsp.*` for documentation on any of the below functions
        local opts = { buffer = ev.buf, silent = true }

        -- set keybinds
        opts.desc = "Show LSP references"
        keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts) -- show definition, references

        opts.desc = "Go to declaration"
        keymap.set("n", "gD", vim.lsp.buf.declaration, opts) -- go to declaration

        opts.desc = "Show LSP definitions"
        keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts) -- show lsp definitions

        opts.desc = "Show LSP implementations"
        keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts) -- show lsp implementations

        opts.desc = "Show LSP type definitions"
        keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts) -- show lsp type definitions

        opts.desc = "See available code actions"
        keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection

        opts.desc = "Smart rename"
        keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts) -- smart rename

        opts.desc = "Show buffer diagnostics"
        keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- show  diagnostics for file

        opts.desc = "Show line diagnostics"
        keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts) -- show diagnostics for line

        opts.desc = "Go to previous diagnostic"
        keymap.set("n", "[d", vim.diagnostic.goto_prev, opts) -- jump to previous diagnostic in buffer

        opts.desc = "Go to next diagnostic"
        keymap.set("n", "]d", vim.diagnostic.goto_next, opts) -- jump to next diagnostic in buffer

        opts.desc = "Show documentation for what is under cursor"
        keymap.set("n", "K", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor

        opts.desc = "Restart LSP"
        keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts) -- mapping to restart lsp if necessary
      end,
    })

    vim.diagnostic.config({
      virtual_text = true,      -- Show diagnostics inline (to the right)
      signs = true,             -- Show signs in the sign column
      update_in_insert = false, -- Don’t update diagnostics while typing
      severity_sort = true,     -- Sort by severity (errors first)
    })

    -- override offset encoding
    local original_make_position_params = vim.lsp.util.make_position_params
    vim.lsp.util.make_position_params = function(window, offset_encoding)
      offset_encoding = offset_encoding or "utf-8" -- Default explicitly
      return original_make_position_params(window, offset_encoding)
    end

    local function get_extension(fname)
      local ext = fname:match("^.+%.([^%.]+)$")
      if not ext then
        return ""
      end

      return ext:lower()
    end

    local ignored_extensions = {
      png = true,
      jpg = true,
      jpeg = true,
      gif = true,
      svg = true,
      webp = true,
      mp4 = true,
      pth = true,
      pt = true,
      json = true,
    }

    local on_attach = function(client, bufnr)
      vim.cmd([[
          augroup lsp_autoformat
            autocmd! * <buffer>
            autocmd BufWritePre <buffer> lua vim.lsp.buf.format(nil, 1000)
          augroup END
        ]], false)

      if client.server_capabilities.document_highlight then
        vim.cmd([[
            hi LspReferenceRead cterm=bold ctermbg=red guibg=LightYellow
            hi LspReferenceText cterm=bold ctermbg=red guibg=LightYellow
            hi LspReferenceWrite cterm=bold ctermbg=red guibg=LightYellow
            augroup lsp_document_highlight
              autocmd! * <buffer>
              autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
              autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
            augroup END
          ]], false)
      end

      local fname = vim.api.nvim_buf_get_name(bufnr)
      local ext = get_extension(fname)

      if ignored_extensions[ext] then
        client.stop()
        return
      end
    end

    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup('lsp_attach_disable_ruff_hover', { clear = true }),
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client == nil then
          return
        end
        if client.name == 'ruff' then
          -- Disable hover in favor of Pyright
          client.server_capabilities.hoverProvider = false
        end
      end,
      desc = 'LSP: Disable hover capability from Ruff',
    })

    -- used to enable autocompletion (assign to every lsp server config)
    local capabilities = cmp_nvim_lsp.default_capabilities()
    capabilities.textDocument.positionEncoding = "utf-8"

    lspconfig.ruff.setup({
      capabilities = capabilities,
      on_attach = on_attach,
      root_dir = vim.fn.getcwd(),
      filetypes = { "python", "typescript", "javascriptreact", "html", "lua" },
    })

    -- configure lua_ls with formatting
    lspconfig.lua_ls.setup({
      capabilities = capabilities,
      on_attach = on_attach,
      format = {
        enable = true,
        defaultConfig = {
          indent_style = "space",
          indent_size = 2,
        }
      },
      root_dir = vim.fn.getcwd(),
      filetypes = { "lua" },
    })

    -- configure pyright server
    lspconfig.pyright.setup({
      capabilities = capabilities,
      on_attach = on_attach,
      init_options = { documentFormatting = true },
      settings = {
        python = {
          analysis = {
            typeCheckingMode = "off",
          },
        },
      },
      root_dir = vim.fn.getcwd(),
      filetypes = { "python" },
    })

    -- configure tsserver language server
    lspconfig.ts_ls.setup({
      capabilities = capabilities,
      on_attach = function(client, bufnr)
        -- Disable ts_ls formatting to avoid conflicts with Prettier
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
        on_attach(client, bufnr) -- Call your existing on_attach function
      end,
      root_dir = vim.fn.getcwd(),
    })

    -- -- configure efm language server
    -- lspconfig.efm.setup({
    --   capabilities = capabilities,
    --   filetypes = { "python", "javascript", "typescript", "javascriptreact", "typescriptreact", "html" },
    --   init_options = { documentFormatting = true },
    --   settings = {
    --     rootMarkers = { ".eslintrc.js", "tsconfig.json", "setup.cfg", "setup.py", ".git/", "train.py", "test.py" },
    --     languages = {
    --       python = { black, flake8, mypy },
    --       javascript = { prettier, eslint },
    --       typescript = { prettier, eslint },
    --       javascriptreact = { prettier, eslint },
    --       typescriptreact = { prettier, eslint },
    --       html = { prettier },
    --     },
    --   },
    --   on_attach = on_attach,
    -- })
    --
    -- -- configure sql language server
    -- -- with formatting
    -- lspconfig.sqlls.setup({
    --   capabilities = capabilities,
    --   on_attach = on_attach,
    --   settings = {
    --     sql = {
    --       formatting = true,
    --     },
    --   },
    -- })
  end,
}
