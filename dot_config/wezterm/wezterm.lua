-- WezTerm configuration
local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- Font configuration (based on Alacritty and Ghostty settings)
config.font = wezterm.font_with_fallback {
  {
    family = 'Hack Nerd Font',
    -- Disable ligatures as per Ghostty config
    harfbuzz_features = { 'calt=0', 'dlig=0', 'liga=0' }
  },
}
config.font_size = 14.0

-- Window configuration (based on Alacritty settings)
config.window_decorations = "RESIZE" -- Similar to Alacritty's "None" but allows resizing
config.window_background_opacity = 1.0
config.window_padding = {
  left = 2,
  right = 2,
  top = 2,
  bottom = 2,
}

-- Scrollback (based on Alacritty settings)
config.scrollback_lines = 10000

-- Shell configuration
config.default_prog = { '/bin/zsh' }

-- Key bindings
config.keys = {
  -- Based on Ghostty's shift+enter binding
  {
    key = 'Enter',
    mods = 'SHIFT',
    action = wezterm.action.SendString '\n',
  },
  -- Quick terminal toggle (similar to Ghostty's alt+t)
  -- Note: WezTerm doesn't have built-in quick terminal, but we can use show/hide
  {
    key = 't',
    mods = 'ALT',
    action = wezterm.action.ToggleFullScreen,
  },
}

-- Tab bar configuration
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false

-- Color scheme (using default for now, can be customized later)
config.color_scheme = 'Tokyo Night'

-- Performance
config.front_end = "WebGpu" -- Use GPU acceleration
config.max_fps = 120

-- Cursor
config.default_cursor_style = 'BlinkingBlock'
config.cursor_blink_rate = 500

-- Other useful settings
config.audible_bell = "Disabled"
config.visual_bell = {
  fade_in_duration_ms = 75,
  fade_out_duration_ms = 75,
  target = 'CursorColor',
}

return config
