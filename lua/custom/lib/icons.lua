--- @module custom.lib.icons
--- Static icon tables used across the configuration.

local M = {}

local ICONS = {
  branch = '',
  bullet = '•',
  open_bullet = '○',
  ok = '✔',
  d_chev = '∨',
  ellipses = '…',
  node = '╼',
  document = '≡',
  lock = '',
  r_chev = '>',
  warning = ' ',
  error = ' ',
  info = '󰌶 ',
}

local KIND_ICONS = {
  Array = ' 󰅪 ',
  BlockMappingPair = ' 󰅩 ',
  Boolean = '  ',
  BreakStatement = ' 󰙧 ',
  Call = ' 󰃷 ',
  CaseStatement = ' 󰨚 ',
  Class = '  ',
  Color = '  ',
  Constant = '  ',
  Constructor = ' 󰆧 ',
  ContinueStatement = '  ',
  Copilot = '  ',
  Declaration = ' 󰙠 ',
  Delete = ' 󰩺 ',
  DoStatement = ' 󰑖 ',
  Element = ' 󰅩 ',
  Enum = '  ',
  EnumMember = '  ',
  Event = '  ',
  Field = '  ',
  File = '  ',
  Folder = '  ',
  ForStatement = '󰑖 ',
  Function = ' 󰆧 ',
  GotoStatement = ' 󰁔 ',
  Identifier = ' 󰀫 ',
  IfStatement = ' 󰇉 ',
  Interface = '  ',
  Keyword = '  ',
  List = ' 󰅪 ',
  Log = ' 󰦪 ',
  Lsp = '  ',
  Macro = ' 󰁌 ',
  Method = ' 󰆧 ',
  Module = ' 󰅩 ',
  Namespace = ' 󰅩 ',
  Null = ' 󰢤 ',
  Number = ' 󰎠 ',
  Object = ' 󰅩 ',
  Operator = '  ',
  Package = ' 󰆧 ',
  Pair = ' 󰅪 ',
  Property = '  ',
  Reference = '  ',
  Regex = '  ',
  Repeat = ' 󰑖 ',
  Return = ' 󰌑 ',
  RuleSet = ' 󰅩 ',
  Scope = ' 󰅩 ',
  Section = ' 󰅩 ',
  Snippet = '  ',
  Specifier = ' 󰦪 ',
  Statement = ' 󰅩 ',
  String = '  ',
  Struct = '  ',
  SwitchStatement = ' 󰨙 ',
  Table = ' 󰅩 ',
  Terminal = '  ',
  Text = ' 󰀬 ',
  Type = '  ',
  TypeParameter = '  ',
  Unit = '  ',
  Value = '  ',
  Variable = '  ',
  WhileStatement = ' 󰑖 ',
}

--- @return table
function M.get_icons()
  return vim.deepcopy(ICONS)
end

--- @return table
function M.get_kind_icons()
  return vim.deepcopy(KIND_ICONS)
end

--- @return table
function M.get_kind_icons_spaced()
  local icons = {}
  for key, value in pairs(KIND_ICONS) do
    icons[key] = value .. ' '
  end
  return icons
end

return M
