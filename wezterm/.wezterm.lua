-- ~/.config/wezterm/wezterm.lua

local wezterm = require 'wezterm'
local act = wezterm.action

-- ========== ДОПОЛНИТЕЛЬНЫЙ КОД (ДО return) ==========
-- Автоматическое восстановление последней сессии и максимизация окна
wezterm.on('gui-startup', function()
    local mux = wezterm.mux
    local tab, pane, window = mux.spawn_window {}
    window:gui_window():maximize()
end)

-- ========== ОСНОВНЫЕ НАСТРОЙКИ (return) ==========
return {
    color_scheme = 'Dracula',
    font = wezterm.font('JetBrains Mono', { weight = 'Regular' }),
    font_size = 13.0,
    harfbuzz_features = { 'calt', 'liga', 'dlig' },
    default_cwd = os.getenv('HOME') .. '/projects',
    enable_tab_bar = true,
    tab_bar_at_bottom = true,

    keys = {
        { key = 'LeftArrow',  mods = 'ALT',        action = act.ActivateTabRelative(-1) },
        { key = 'RightArrow', mods = 'ALT',        action = act.ActivateTabRelative(1) },
        { key = '|',          mods = 'CTRL|SHIFT', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
        { key = '-',          mods = 'CTRL|SHIFT', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
        { key = 'x',          mods = 'CTRL|SHIFT', action = act.CloseCurrentPane { confirm = false } },
        { key = 'h',          mods = 'ALT',        action = act.ActivatePaneDirection 'Left' },
        { key = 'l',          mods = 'ALT',        action = act.ActivatePaneDirection 'Right' },
        { key = 'k',          mods = 'ALT',        action = act.ActivatePaneDirection 'Up' },
        { key = 'j',          mods = 'ALT',        action = act.ActivatePaneDirection 'Down' },
        { key = 'f',          mods = 'CTRL|SHIFT', action = act.Search { CaseSensitiveString = '' } },
    },

    enable_wayland = false,
    front_end = 'WebGpu',
    webgpu_power_preference = 'HighPerformance',
    check_for_updates = false,
}
