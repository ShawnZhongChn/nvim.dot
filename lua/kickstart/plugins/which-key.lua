return {
  'folke/which-key.nvim',
  event = 'VeryLazy', -- 改为 VeryLazy，启动速度更快且不影响首屏加载
  opts = {
    -- 极致响应性能
    delay = 0,
    -- 现代化的 UI 风格
    preset = 'helix', -- 比默认的 classic 更清爽，适合 4K 屏幕

    icons = {
      mappings = vim.g.have_nerd_font,
      -- 如果有 Nerd Font，Keys 设为 {} 会自动使用漂亮的高清图标
      keys = vim.g.have_nerd_font and {} or {
        Up = 'UP ',
        Down = 'DN ',
        Left = 'LT ',
        Right = 'RT ',
        C = 'C-',
        M = 'M-',
        D = 'D-',
        S = 'S-',
        CR = 'RET ',
        Esc = 'ESC ',
        Tab = 'TAB ',
        BS = 'BACK ',
        Space = 'SPC ',
      },
    },

    -- 窗口样式优化
    win = {
      -- 既然你在 Arch/Hyprland 下可能用了透明效果，这里可以微调
      border = 'rounded', -- 圆角边框更现代
      padding = { 1, 2 }, -- 增加一点呼吸感
      wo = {
        winblend = 5, -- 保持微弱透明度，呼应你的 Hyprland 风格
      },
    },

    -- 快捷键组定义 (V3 Spec 语法)
    spec = {
      { '<leader>c', group = '[C]ode', mode = { 'n', 'x' } },
      { '<leader>d', group = '[D]ocument' },
      { '<leader>r', group = '[R]ename' },
      { '<leader>s', group = '[S]earch' },
      { '<leader>w', group = '[W]orkspace' },
      { '<leader>t', group = '[T]oggle' },
      { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },

      -- 专门为你的 Oil.nvim 增加一个直观的组
      { '<leader>f', group = '[F]iles / Oil' },

      -- 增加窗口代理提示
      { '<leader>q', proxy = '<c-w>', group = '[W]indows' },
    },
  },
}
