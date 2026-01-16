local function disable_lsp_formatting(client)
  client.server_capabilities.documentFormattingProvider = false
  client.server_capabilities.documentRangeFormattingProvider = false
end

return {
  -----------------------------------------------------------------------------
  -- 1. 核心补全引擎 (Blink.cmp - 替代 nvim-cmp)
  -----------------------------------------------------------------------------
  {
    "saghen/blink.cmp",
    version = "*",
    opts = {
      keymap = {
        preset = "none",
        ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-e>"] = { "hide" },
        ["<Tab>"] = { "accept", "fallback" }, -- 接受建议或 fallback
        ["<Up>"] = { "select_prev", "fallback" },
        ["<Down>"] = { "select_next", "fallback" },
        ["<C-p>"] = { "select_prev", "fallback" },
        ["<C-n>"] = { "select_next", "fallback" },
        ["<C-b>"] = { "scroll_documentation_up", "fallback" },
        ["<C-f>"] = { "scroll_documentation_down", "fallback" },
      },
      appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = "mono",
      },
      completion = {
        list = { selection = { preselect = true, auto_insert = true } },
        menu = { border = "rounded" },
        documentation = { window = { border = "rounded" }, auto_show = true },
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },
    },
  },

  -- 禁用 lspimport 以防冲突
  { "stevanmilic/nvim-lspimport", enabled = false },

  -----------------------------------------------------------------------------
  -- 2. LSP 配置 (集成 BasedPyright 修复)
  -----------------------------------------------------------------------------
  {
    "neovim/nvim-lspconfig",
    opts = {
      diagnostics = {
        virtual_text = false,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        float = { border = "rounded", source = "always" },
      },

      servers = {
        -- 禁用可能冲突的 Server
        pyright = false,

        -- Python: BasedPyright
        basedpyright = {
          enabled = true,

          -- 强制指定命令路径：优先 Mason，其次 PATH（兼容 Windows .cmd）
          cmd = (function()
            local bin = vim.fn.stdpath("data") .. "/mason/bin/basedpyright-langserver"
            if vim.fn.executable(bin) == 1 then
              return { bin, "--stdio" }
            end
            if vim.fn.executable(bin .. ".cmd") == 1 then
              return { bin .. ".cmd", "--stdio" }
            end
            return { "basedpyright-langserver", "--stdio" }
          end)(),

          filetypes = { "python" },
          single_file_support = true,

          -- Neovim 0.11+ root_dir 签名 (bufnr, on_dir)；同时兼容旧返回值写法
          root_dir = function(bufnr, on_dir)
            local util = require("lspconfig.util")

            local fname = bufnr
            if type(bufnr) == "number" then
              fname = vim.api.nvim_buf_get_name(bufnr)
            end
            if type(fname) ~= "string" or fname == "" then
              return nil
            end

            local root = util.root_pattern(
              ".git",
              "pyproject.toml",
              "setup.py",
              "setup.cfg",
              "requirements.txt",
              "Pipfile",
              "poetry.lock",
              "pyrightconfig.json"
            )(fname) or util.path.dirname(fname)

            if type(on_dir) == "function" then
              on_dir(root)
              return
            end
            return root
          end,

          settings = {
            basedpyright = {
              -- 防止与 Ruff/其它工具抢“整理导入”
              disableOrganizeImports = true,

              analysis = {
                -- 对齐你的 TOML
                typeCheckingMode = "standard",
                useLibraryCodeForTypes = true,

                autoImportCompletions = true,
                diagnosticMode = "workspace",

                -- 严格性降级（PyCharm 模拟器）
                reportAny = "none",
                reportExplicitAny = "none",
                reportUnknownVariableType = "none",
                reportUnknownMemberType = "none",
                reportUnknownParameterType = "none",
                reportUnknownArgumentType = "none",
                reportMissingTypeStubs = "none",
                reportPrivateUsage = "none",

                -- 关键：动态属性别炸红
                reportAttributeAccessIssue = "warning",

                reportUnusedImport = "warning",
                reportUnusedVariable = "warning",
                reportUnreachable = "warning",

                -- 视觉降噪
                inlayHints = {
                  variableTypes = false,
                  functionReturnTypes = false,
                },
              },
            },
          },
        },

        -- Python: Ruff（lint / code actions；hover 建议交给 basedpyright）
        ruff = {
          enabled = true,

          -- Ruff LSP 默认就是 `ruff server`（同样优先 Mason；兼容 Windows .cmd）
          cmd = (function()
            local bin = vim.fn.stdpath("data") .. "/mason/bin/ruff"
            if vim.fn.executable(bin) == 1 then
              return { bin, "server" }
            end
            if vim.fn.executable(bin .. ".cmd") == 1 then
              return { bin .. ".cmd", "server" }
            end
            return { "ruff", "server" }
          end)(),

          init_options = {
            settings = {
              -- 需要的话把 ruff server 的设置写这里（一般会自动读取项目里的配置文件）
            },
          },

          on_attach = function(client, _bufnr)
            -- 避免 hover 冲突：hover/补全/跳转交给 basedpyright
            client.server_capabilities.hoverProvider = false
          end,
        },

        -- Frontend: TypeScript/JavaScript
        tsserver = {
          on_attach = disable_lsp_formatting,
          init_options = { hostInfo = "neovim" },
        },
        eslint = {
          on_attach = disable_lsp_formatting,
          settings = {
            workingDirectory = { mode = "auto" },
            format = false,
          },
        },
        cssls = { on_attach = disable_lsp_formatting },
        html = { on_attach = disable_lsp_formatting },
        jsonls = { on_attach = disable_lsp_formatting },
        emmet_ls = {
          filetypes = {
            "html",
            "css",
            "scss",
            "javascript",
            "javascriptreact",
            "typescript",
            "typescriptreact",
          },
        },
        tailwindcss = {},
      },
    },
  },
  -----------------------------------------------------------------------------
  -- 3. Mason 工具链
  -----------------------------------------------------------------------------
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      -- Remove pyright if LazyVim defaults add it.
      for i = #opts.ensure_installed, 1, -1 do
        if opts.ensure_installed[i] == "pyright" then
          table.remove(opts.ensure_installed, i)
        end
      end
      if not vim.tbl_contains(opts.ensure_installed, "basedpyright") then
        table.insert(opts.ensure_installed, "basedpyright")
      end
    end,
  },
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        -- TS/JS/React
        "eslint_d",
        "prettierd",
        "typescript-language-server",
        "eslint-lsp",
        "css-lsp",
        "html-lsp",
        "json-lsp",
        "emmet-ls",
        "js-debug-adapter",
        "tailwindcss-language-server",
        -- Python
        "basedpyright",
        "black",
        "isort",
        "debugpy",
      })
    end,
  },

  -----------------------------------------------------------------------------
  -- 4. 格式化 (Conform) & 代码检查 (Lint)
  -----------------------------------------------------------------------------
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        javascript = { "prettierd" },
        typescript = { "prettierd" },
        javascriptreact = { "prettierd" },
        typescriptreact = { "prettierd" },
        css = { "prettierd" },
        scss = { "prettierd" },
        html = { "prettierd" },
        json = { "prettierd" },
        python = { "isort", "black" },
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
      linters_by_ft = {
        javascript = {},
        typescript = {},
        javascriptreact = {},
        typescriptreact = {},
      },
    },
  },

  -----------------------------------------------------------------------------
  -- 5. Python 虚拟环境 (Miniconda 增强)
  -----------------------------------------------------------------------------
  {
    "linux-cultist/venv-selector.nvim",
    branch = "main",
    dependencies = { "neovim/nvim-lspconfig", "nvim-telescope/telescope.nvim", "mfussenegger/nvim-dap-python" },
    opts = function(_, opts)
      local home = vim.env.HOME
      local conda_root = vim.env.CONDA_PREFIX or (home and (home .. "/miniconda3") or nil)
      opts.settings = {
        options = { notify_user_on_venv_activation = true },
        search = {
          conda = {
            command = conda_root and (string.format("fd /python$ %s/envs --full-path --color never", conda_root))
              or nil,
          },
        },
      }
    end,
    keys = {
      { "<leader>cv", "<cmd>VenvSelect<cr>", desc = "Select VirtualEnv" },
    },
  },

  -----------------------------------------------------------------------------
  -- 6. 调试 (DAP) & 测试 (Neotest)
  -----------------------------------------------------------------------------
  {
    "mfussenegger/nvim-dap",
    optional = true,
    dependencies = {
      "mfussenegger/nvim-dap-python",
      "mxsdev/nvim-dap-vscode-js",
      "jay-babu/mason-nvim-dap.nvim",
    },
    config = function()
      local dap = require("dap")
      -- JS/TS Debug
      require("dap-vscode-js").setup({
        debugger_path = vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter",
        adapters = { "pwa-node", "pwa-chrome" },
      })
      for _, lang in ipairs({ "javascript", "typescript", "typescriptreact" }) do
        dap.configurations[lang] = {
          {
            type = "pwa-node",
            request = "launch",
            name = "Launch file",
            program = "${file}",
            cwd = "${workspaceFolder}",
          },
        }
      end
      -- Python Debug
      require("dap-python").setup(vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python")
    end,
  },
  {
    "nvim-neotest/neotest",
    optional = true,
    dependencies = { "nvim-neotest/neotest-jest", "nvim-neotest/neotest-python" },
    opts = function(_, opts)
      opts.adapters = opts.adapters or {}
      table.insert(opts.adapters, require("neotest-jest")({ jestCommand = "npm test --" }))
      table.insert(opts.adapters, require("neotest-python")({ runner = "pytest" }))
    end,
  },

  -----------------------------------------------------------------------------
  -- 7. 界面与交互优化
  -----------------------------------------------------------------------------
  {
    "folke/flash.nvim",
    opts = { modes = { char = { enabled = false } } },
    keys = {
      { "s", mode = { "n", "x", "o" }, false },
      { "S", mode = { "n", "x", "o" }, false },
      {
        "<leader>j",
        mode = { "n", "x", "o" },
        function()
          require("flash").jump()
        end,
        desc = "Flash",
      },
    },
  },
  {
    "nvim-mini/mini.surround",
    opts = {
      mappings = {
        add = "sa",
        delete = "sd",
        find = "sf",
        find_left = "sF",
        highlight = "sh",
        replace = "sr",
        update_n_lines = "sn",
      },
    },
  },

  -----------------------------------------------------------------------------
  -- 8. Treesitter 语法高亮
  -----------------------------------------------------------------------------
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, {
          "bash",
          "html",
          "javascript",
          "json",
          "lua",
          "markdown",
          "python",
          "tsx",
          "typescript",
          "yaml",
          "regex",
          "css",
        })
      end
    end,
  },

  -----------------------------------------------------------------------------
  -- 9. Docker
  -----------------------------------------------------------------------------
  {
    "crnvl96/lazydocker.nvim",
    event = "VeryLazy",
    opts = {}, -- automatically calls require("lazydocker").setup()
    keys = {
      {
        "<leader>dd",
        "<cmd>lua require('lazydocker').toggle({ engine = 'docker' })<cr>",
        desc = "Open LazyDocker",
        mode = { "n", "t" },
      },
    },
  },
}
