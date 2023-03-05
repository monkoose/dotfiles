local wezterm = require('wezterm')
local act = wezterm.action
local home = os.getenv('HOME')

return {
  enable_tab_bar = false,
  scrollback_lines = 1000,
  font = wezterm.font_with_fallback {
    'Iosevka Monkoose',
    'IosevkaTerm Nerd Font Mono',
  },
  font_dirs = { home .. '/.fonts' },
  font_locator = 'ConfigDirsOnly',
  font_size = 13,
  freetype_load_target = 'HorizontalLcd',
  freetype_load_flags = 'NO_AUTOHINT|MONOCHROME',
  harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' },
  cursor_thickness = 2,
  automatically_reload_config = false,
  quick_select_alphabet = 'fjdklsaeghiowrucm',
  max_fps = 120,
  underline_position = -3,
  use_ime = false,
  -- term = 'wezterm',
  initial_rows = 33,
  initial_cols = 151,
  window_padding = {
    left = 1,
    right = 1,
    top = 6,
    bottom = 2,
  },

  colors = {
    foreground = '#b8af96',
    background = '#110e0d',
    cursor_bg = '#d02a61',
    cursor_fg = '201b17',
    cursor_border = '#d02a61',
    selection_fg = 'none',
    selection_bg = '483c19',
    ansi = {
      '#110e0d',
      '#d35b4b',
      '#8f9e44',
      '#c57c41',
      '#7680ac',
      '#b2809f',
      '#70a195',
      '#b8af96',
    },
    brights = {
      '#6e685a',
      '#d35b4b',
      '#8f9e44',
      '#caa247',
      '#7680ac',
      '#b2809f',
      '#70a195',
      '#b8af96',
    },
    compose_cursor = 'orange',
    copy_mode_active_highlight_bg = { Color = '#253830' },
    copy_mode_active_highlight_fg = { Color = '#cccccc' },
    copy_mode_inactive_highlight_bg = { Color = '#293045' },
    copy_mode_inactive_highlight_fg = { Color = '#cccccc' },

    quick_select_label_bg = { Color = '#612011' },
    quick_select_label_fg = { Color = '#eeeeee' },
    quick_select_match_bg = { Color = '#293045' },
    quick_select_match_fg = { Color = '#cccccc' },
  },

  keys = {
    { mods = 'CTRL|SHIFT', key = 'l', action = act.ClearScrollback('ScrollbackAndViewport') },
    { mods = 'CTRL|SHIFT', key = 'k', action = act.ScrollByPage(-0.5) },
    { mods = 'CTRL|SHIFT', key = 'j', action = act.ScrollByPage(0.5) },
    { mods = 'CTRL|SHIFT', key = 'r', action = act.ReloadConfiguration },
  },

  key_tables = {
    search_mode = {
      { key = 'Enter', mods = 'NONE', action = act.CopyMode 'Close' },
      { key = 'Escape', mods = 'NONE', action = act.CopyMode 'Close' },
      { mods = 'CTRL', key = 'j', action = act.CopyMode 'NextMatch' },
      { mods = 'CTRL', key = 'k', action = act.CopyMode 'PriorMatch' },
      { key = 'r', mods = 'CTRL', action = act.CopyMode 'CycleMatchType' },
      { key = 'w', mods = 'CTRL', action = act.CopyMode 'ClearPattern' },
      { key = 'u', mods = 'CTRL', action = act.CopyMode 'ClearPattern' },
    }
  }
}
