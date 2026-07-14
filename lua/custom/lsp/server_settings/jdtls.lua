--- @module custom.lsp.server_settings.jdtls
--- Java language server settings for Maven/Spring/Lombok projects.

local M = {}

local function _mason_package_path(package)
  return vim.fn.stdpath 'data' .. '/mason/packages/' .. package
end

local function _mason_bin_path(executable)
  return vim.fn.stdpath 'data' .. '/mason/bin/' .. executable
end

local function _jdtls_cache_dir()
  return vim.fn.stdpath 'cache' .. '/jdtls'
end

local function _jdtls_workspace_dir(root_dir)
  local project = root_dir and vim.fs.basename(vim.fs.normalize(root_dir)) or 'default'
  return _jdtls_cache_dir() .. '/workspace/' .. project
end

local function _existing_file(path)
  return path and vim.uv.fs_stat(path) and path or nil
end

local function _lombok_jar()
  return _existing_file(_mason_package_path 'jdtls' .. '/lombok.jar')
end

local function _spring_boot_bundles()
  local package_path = _mason_package_path 'vscode-spring-boot-tools'
  local bundles = vim.fn.glob(package_path .. '/jdtls/*.jar', true, true)
  vim.list_extend(bundles, vim.fn.glob(package_path .. '/extension/jars/*.jar', true, true))
  return bundles
end

local function _java_home_runtime()
  if vim.env.JAVA_HOME and vim.env.JAVA_HOME ~= '' then
    return {
      name = 'JavaSE-21',
      path = vim.env.JAVA_HOME,
      default = true,
    }
  end
end

local function _project_root(bufnr)
  local path = vim.api.nvim_buf_get_name(bufnr)
  local root = vim.fs.root(bufnr, { 'pom.xml', 'mvnw', '.git' })

  if root then
    return root
  end

  if path ~= '' then
    return vim.fs.dirname(vim.fs.normalize(path))
  end

  return vim.fn.getcwd()
end

local function _jdtls_command(root_dir)
  local cmd = {
    _existing_file(_mason_bin_path 'jdtls') or 'jdtls',
    '-data',
    _jdtls_workspace_dir(root_dir),
  }

  local env_args = vim.split(vim.env.JDTLS_JVM_ARGS or '', '%s+', { trimempty = true })
  for _, arg in ipairs(env_args) do
    table.insert(cmd, '--jvm-arg=' .. arg)
  end

  local lombok = _lombok_jar()
  if lombok then
    table.insert(cmd, '--jvm-arg=-javaagent:' .. lombok)
  else
    vim.schedule(function()
      vim.notify('JDTLS: Mason jdtls lombok.jar not found; Lombok-generated members may be incomplete', vim.log.levels.WARN)
    end)
  end

  if vim.fn.executable 'java' ~= 1 and (not vim.env.JAVA_HOME or vim.env.JAVA_HOME == '') then
    vim.schedule(function()
      vim.notify('JDTLS: no Java runtime found. Install a JDK or set JAVA_HOME before starting Java LSP.', vim.log.levels.ERROR)
    end)
  end

  return cmd
end

local runtimes = {}
local runtime = _java_home_runtime()
if runtime then
  table.insert(runtimes, runtime)
end

--- @param bufnr integer|nil
--- @return table
function M.make_config(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local root_dir = _project_root(bufnr)
  local jdtls = require 'jdtls'

  local extended_client_capabilities = vim.deepcopy(jdtls.extendedClientCapabilities)
  extended_client_capabilities.resolveAdditionalTextEditsSupport = true

  return {
    cmd = _jdtls_command(root_dir),
    root_dir = root_dir,
    capabilities = require('custom.lsp.capabilities').make(),
    filetypes = { 'java' },
    settings = {
      java = {
        configuration = {
          runtimes = runtimes,
          updateBuildConfiguration = 'interactive',
        },
        maven = {
          downloadSources = true,
        },
        import = {
          generatesMetadataFilesAtProjectRoot = false,
          maven = {
            enabled = true,
          },
          gradle = {
            enabled = false,
          },
        },
        completion = {
          favoriteStaticMembers = {
            'org.junit.jupiter.api.Assertions.*',
            'org.mockito.Mockito.*',
            'org.springframework.test.web.servlet.result.MockMvcResultMatchers.*',
          },
          importOrder = { 'java', 'javax', 'jakarta', 'org', 'com' },
        },
        sources = {
          organizeImports = {
            starThreshold = 9999,
            staticStarThreshold = 9999,
          },
        },
        saveActions = {
          organizeImports = true,
        },
        format = {
          enabled = true,
          comments = {
            enabled = true,
          },
        },
        referencesCodeLens = {
          enabled = true,
        },
        implementationsCodeLens = {
          enabled = true,
        },
        inlayHints = {
          parameterNames = {
            enabled = 'all',
          },
        },
      },
      spring = {
        boot = {
          validation = {
            enabled = true,
          },
        },
      },
    },
    init_options = {
      bundles = _spring_boot_bundles(),
      extendedClientCapabilities = extended_client_capabilities,
    },
  }
end

return M
