--[[
--
-- This file is not required for your own configuration,
-- but helps people determine if their system is setup correctly.
--
--]]

local check_version = function()
  local verstr = tostring(vim.version())
  if not vim.version.ge then
    vim.health.error(string.format("Neovim out of date: '%s'. Upgrade to latest stable or nightly", verstr))
    return
  end

  if vim.version.ge(vim.version(), '0.10-dev') then
    vim.health.ok(string.format("Neovim version is: '%s'", verstr))
  else
    vim.health.error(string.format("Neovim out of date: '%s'. Upgrade to latest stable or nightly", verstr))
  end
end

local check_external_reqs = function()
  -- Basic utils: `git`, `make`, `unzip`
  for _, exe in ipairs { 'git', 'make', 'unzip', 'rg' } do
    local is_executable = vim.fn.executable(exe) == 1
    if is_executable then
      vim.health.ok(string.format("Found executable: '%s'", exe))
    else
      vim.health.warn(string.format("Could not find executable: '%s'", exe))
    end
  end

  return true
end

local check_java_reqs = function()
  vim.health.start 'Java development'

  if vim.fn.executable 'java' == 1 then
    vim.health.ok "Found executable: 'java'"
  elseif vim.env.JAVA_HOME and vim.env.JAVA_HOME ~= '' then
    vim.health.ok 'JAVA_HOME is set; jdtls can use this JDK runtime'
  else
    vim.health.warn 'Could not find a JDK. Run scripts/setup_java_sdkman.sh or install OpenJDK 21+ and set JAVA_HOME before starting jdtls.'
  end

  if vim.fn.executable 'mvn' == 1 then
    vim.health.ok "Found executable: 'mvn'"
  else
    vim.health.warn 'Could not find Maven executable: mvn. Run scripts/setup_java_sdkman.sh, or use Maven wrapper projects via ./mvnw.'
  end

  local mason_jdtls = vim.fn.stdpath 'data' .. '/mason/packages/jdtls'
  if vim.uv.fs_stat(mason_jdtls .. '/lombok.jar') then
    vim.health.ok 'Found Mason jdtls Lombok agent jar'
  else
    vim.health.info 'Mason will install jdtls and its Lombok jar when auto_install_tools is enabled.'
  end
end

return {
  check = function()
    vim.health.start 'kickstart.nvim'

    vim.health.info [[NOTE: Not every warning is a 'must-fix' in `:checkhealth`

  Fix only warnings for plugins and languages you intend to use.
    Mason will give warnings for languages that are not installed.
    You do not need to install, unless you want to use those languages!]]

    local uv = vim.uv
    vim.health.info('System Information: ' .. vim.inspect(uv.os_uname()))

    check_version()
    check_external_reqs()
    check_java_reqs()
  end,
}
