---@Note: Configuration for tiny-inline-diagnostic.nvim
---Provides a modernized, inline diagnostic display with visual enhancements.

--------------------------------------------------------------------------------
-- Options Components
--------------------------------------------------------------------------------

---构建并返回插件的核心配置表
---@return table
local function _get_opts()
  return {
    preset = 'powerline',
    transparent_background = false,
    show_source = true,
    show_message = true,
    overflow = {
      mode = 'wrap',
    },
    break_line = {
      enabled = false,
      chunk_size = 20,
    },
  }
end

--------------------------------------------------------------------------------
-- Enhancement Methods
--------------------------------------------------------------------------------

---应用必要的环境增强设置
---@Note: 此插件通常需要禁用 Neovim 原生的 virtual_text 以避免显示冲突
local function _apply_global_tweaks()
  vim.diagnostic.config {
    virtual_text = false,
  }
end

---复制当前行及关联的诊断信息到剪贴板
---@Note: 格式为：代码行 \n 报错信息
local function _copy_line_and_diagnostic()
  local current_line = vim.api.nvim_get_current_line()
  local row = vim.api.nvim_win_get_cursor(0)[1] - 1
  local diags = vim.diagnostic.get(0, { lnum = row })

  if #diags == 0 then
    vim.notify('当前行无诊断信息', vim.log.levels.WARN)
    return
  end

  -- 获取第一条诊断信息 (通常是最重要的)
  local diag_msg = diags[1].message
  local content = current_line .. '\n' .. diag_msg

  -- 写入系统剪贴板 (+)
  vim.fn.setreg('+', content)
  vim.notify('已复制行与诊断信息', vim.log.levels.INFO)
end

---设置相关的快捷键映射
---@param bufnr number|nil
local function _set_keymaps(bufnr)
  -- 绑定复制诊断功能的快捷键 (CP = Copy Problem)
  vim.keymap.set('n', '<leader>cp', _copy_line_and_diagnostic, { desc = 'Copy Line & Diagnostic' })
end

--------------------------------------------------------------------------------
-- Core Logic
--------------------------------------------------------------------------------

---插件初始化逻辑
---@param _ any Lazy 传入的插件对象 (unused)
---@param opts table 由 Lazy 处理后的配置表
local function _config(_, opts)
  _apply_global_tweaks()
  require('tiny-inline-diagnostic').setup(opts)
  _set_keymaps()
end

--------------------------------------------------------------------------------
-- Plugin Spec
--------------------------------------------------------------------------------

---@return table Lazy.nvim plugin specification
return {
  'rachartier/tiny-inline-diagnostic.nvim',
  event = 'LspAttach',
  priority = 1000,
  opts = _get_opts(),
  config = _config,
}
