return {
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    opts = {},
  },
  {
    "neovim/nvim-lspconfig",
    lazy = false,
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = { "pyright", "ruff", "lua_ls" },
        automatic_installation = true,
      })

      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
        callback = function(ev)
          local opts = { buffer = ev.buf, remap = false }
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "gy", vim.lsp.buf.type_definition, opts)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
          vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
          vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
        end,
      })

      local function configure_server(server_name, opts)
        opts = opts or {}
        opts.capabilities = capabilities

        if vim.lsp.config then
          vim.lsp.config(server_name, opts)
          vim.lsp.enable(server_name)
        else
          require("lspconfig")[server_name].setup(opts)
        end
      end

      local function find_python_executable(start_dir)
        if vim.env.VIRTUAL_ENV then
          return vim.env.VIRTUAL_ENV .. "/bin/python"
        end
        local dir = start_dir or vim.fn.getcwd()
        while dir and dir ~= "" and dir ~= "/" do
          for _, venv_name in ipairs({ ".venv", "venv", "env" }) do
            local candidate = dir .. "/" .. venv_name .. "/bin/python"
            if vim.fn.executable(candidate) == 1 then
              return candidate
            end
          end
          local parent = vim.fn.fnamemodify(dir, ":h")
          if parent == dir then break end
          dir = parent
        end
        return vim.fn.exepath("python3") or "python"
      end

      local function apply_python_venv(settings, root_dir)
        local python_path = find_python_executable(root_dir)
        settings.python = settings.python or {}
        settings.python.pythonPath = python_path

        local extra_paths = {}
        if python_path:find("/bin/python$") then
          local venv_dir = vim.fn.fnamemodify(python_path, ":h:h")
          settings.python.venvPath = vim.fn.fnamemodify(venv_dir, ":h")
          settings.python.venv = vim.fn.fnamemodify(venv_dir, ":t")

          local lib_dir = venv_dir .. "/lib"
          local site_packages = vim.fn.glob(lib_dir .. "/python*/site-packages", true, true)
          for _, p in ipairs(site_packages) do
            table.insert(extra_paths, p)
          end
        end

        if #extra_paths > 0 then
          settings.python.analysis = settings.python.analysis or {}
          settings.python.analysis.extraPaths = extra_paths
        end
      end

      configure_server("pyright", {
        before_init = function(_, config)
          config.settings = config.settings or {}
          apply_python_venv(config.settings, config.root_dir)
        end,
        on_new_config = function(new_config, new_root_dir)
          new_config.settings = new_config.settings or {}
          apply_python_venv(new_config.settings, new_root_dir)
        end,
        settings = {
          python = {
            analysis = {
              typeCheckingMode = "basic",
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              indexing = true,
              diagnosticMode = "openFilesOnly",
            },
          },
        },
      })

      configure_server("ruff", {})
      configure_server("lua_ls", {
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            diagnostics = { globals = { "vim" } },
            workspace = { library = vim.api.nvim_get_runtime_file("", true) },
          },
        },
      })
    end,
  },
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>f",
        function()
          require("conform").format({ async = true, lsp_fallback = true })
        end,
        mode = "",
        desc = "Format buffer",
      },
    },
    opts = {
      formatters_by_ft = {
        python = { "ruff_organize_imports", "ruff_format" },
        lua = { "stylua" },
      },
      format_on_save = { timeout_ms = 1000, lsp_fallback = true },
    },
  },
}
