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

    -- Change the Diagnostic symbols in the sign column (gutter)
    -- (not in youtube nvim video)
    local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
    for type, icon in pairs(signs) do
      local hl = "DiagnosticSign" .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
    end


    local on_attach = function(client, _)
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
    end

    -- setup formatters and linters
    local eslint = {
      lintCommand = "eslint_d -f unix --stdin --stdin-filename ${INPUT}",
      lintIgnoreExitCode = true,
      lintStdin = true,
      lintFormats = { "%f:%l:%c: %m" },
    }

    local prettier = {
      formatCommand = "prettier ${INPUT}",
      formatStdin = true,
    }

    local black = {
      formatCommand = "black --quiet -",
      formatStdin = true,
    }

    local flake8 = {
      lintCommand = "./.venv/bin/flake8 --stdin-display-name ${INPUT} -",
      lintStdin = true,
      lintFormats = { "%f:%l:%c: %m" },
    }

    local mypy = {
      lintCommand = "mypy --show-column-numbers",
      lintFormats = {
        "%f:%l:%c: %trror: %m",
        "%f:%l:%c: %tarning: %m",
        "%f:%l:%c: %tote: %m",
      },
    }

    -- used to enable autocompletion (assign to every lsp server config)
    local capabilities = cmp_nvim_lsp.default_capabilities()

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
    })

    -- configure tsserver language server
    lspconfig.tsserver.setup({
      capabilities = capabilities,
      on_attach = on_attach,
    })


    -- configure efm language server
    lspconfig.efm.setup({
      capabilities = capabilities,
      filetypes = { "python", "javascript", "typescript", "javascriptreact", "typescriptreact", "html" },
      init_options = { documentFormatting = true },
      settings = {
        rootMarkers = { ".eslintrc.js", "tsconfig.json", "setup.cfg", "setup.py", ".git/" },
        languages = {
          python = { black, flake8, mypy },
          javascript = { prettier, eslint },
          typescript = { prettier, eslint },
          javascriptreact = { prettier, eslint },
          typescriptreact = { prettier, eslint },
          html = { prettier },
        },
      },
      on_attach = on_attach,
    })
  end,
}
