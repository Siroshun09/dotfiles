local wezterm = require 'wezterm'
local act = wezterm.action

local config = wezterm.config_builder and wezterm.config_builder() or {}

config.color_scheme = 'Dracula+'
config.hide_tab_bar_if_only_one_tab = false

config.font = wezterm.font_with_fallback({
  { family = 'Source Han Code JP', weight = 'Bold' },
  'JetBrains Mono',
  'SF Mono',
  'Symbols Nerd Font',
  'Apple Color Emoji',
})
config.font_size = 11.0

config.use_ime = true
config.macos_forward_to_ime_modifier_mask = 'SHIFT|CTRL|ALT|SUPER'

config.default_prog = { '/bin/zsh', '-l' }
config.initial_cols = 100
config.initial_rows = 25
config.front_end = 'WebGpu'
config.max_fps = 60
config.animation_fps = 60

config.scrollback_lines = 100000
config.enable_scroll_bar = true
config.adjust_window_size_when_changing_font_size = false
config.audible_bell = 'Disabled'

config.colors = config.colors or {}
config.colors.selection_bg = '#2c4181'
config.colors.selection_fg = 'none'
config.colors.scrollbar_thumb = '#6e6e6e'

config.keys = config.keys or {}
table.insert(config.keys, { key = 'Enter', mods = 'SHIFT', action = wezterm.action.SendString('\n') })

table.insert(config.keys, { key = 'f', mods = 'CMD', action = act.Search('CurrentSelectionOrEmptyString') })
table.insert(config.keys, { key = 'f', mods = 'CMD|SHIFT', action = act.Search({ CaseSensitiveString = '' }) })
table.insert(config.keys, { key = 'f', mods = 'CMD|ALT', action = act.Search({ Regex = '' }) })
table.insert(config.keys, { key = 'g', mods = 'CMD', action = act.ActivateCommandPalette })

table.insert(config.keys, { key = 'LeftArrow',  mods = 'ALT', action = act.ActivatePaneDirection('Left') })
table.insert(config.keys, { key = 'RightArrow', mods = 'ALT', action = act.ActivatePaneDirection('Right') })
table.insert(config.keys, { key = 'UpArrow',    mods = 'ALT', action = act.ActivatePaneDirection('Up') })
table.insert(config.keys, { key = 'DownArrow',  mods = 'ALT', action = act.ActivatePaneDirection('Down') })

table.insert(config.keys, { key = 'LeftArrow',  mods = 'ALT|SHIFT', action = act.AdjustPaneSize({ 'Left', 3 }) })
table.insert(config.keys, { key = 'RightArrow', mods = 'ALT|SHIFT', action = act.AdjustPaneSize({ 'Right', 3 }) })
table.insert(config.keys, { key = 'UpArrow',    mods = 'ALT|SHIFT', action = act.AdjustPaneSize({ 'Up', 1 }) })
table.insert(config.keys, { key = 'DownArrow',  mods = 'ALT|SHIFT', action = act.AdjustPaneSize({ 'Down', 1 }) })

table.insert(config.keys, { key = '-', mods = 'ALT',       action = act.SplitVertical({ domain = 'CurrentPaneDomain' }) })
table.insert(config.keys, { key = '|', mods = 'ALT|SHIFT', action = act.SplitHorizontal({ domain = 'CurrentPaneDomain' }) })

return config
