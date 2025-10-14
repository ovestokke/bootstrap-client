-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

-- Set default shell based on platform
if wezterm.target_triple == 'x86_64-pc-windows-msvc' or wezterm.target_triple == 'aarch64-pc-windows-msvc' then
  config.default_prog = { 'pwsh.exe' }
elseif wezterm.target_triple == 'x86_64-apple-darwin' or wezterm.target_triple == 'aarch64-apple-darwin' then
  config.default_prog = { 'zsh' }
end

config.color_scheme = 'Catppuccin Mocha'
-- config.color_scheme = 'Lunaria Dark (Gogh)'
config.font = wezterm.font("MesloLGS NF")
config.font_size = 12

-- Set initial window size (columns x rows)
config.initial_cols = 120
config.initial_rows = 30

config.enable_tab_bar = true

config.window_decorations = "RESIZE"

config.window_background_opacity = 0.98
config.macos_window_background_blur = 10

-- my coolnight colorscheme (comment out if using color_scheme above):
-- config.colors = {
-- 	foreground = "#CBE0F0",
-- 	background = "#011423",
-- 	cursor_bg = "#47FF9C",
-- 	cursor_border = "#47FF9C",
-- 	cursor_fg = "#011423",
-- 	selection_bg = "#033259",
-- 	selection_fg = "#CBE0F0",
-- 	ansi = { "#214969", "#E52E2E", "#44FFB1", "#FFE073", "#0FC5ED", "#a277ff", "#24EAF7", "#24EAF7" },
-- 	brights = { "#214969", "#E52E2E", "#44FFB1", "#FFE073", "#A277FF", "#a277ff", "#24EAF7", "#24EAF7" },
-- }

-- Define leader key for cross-platform compatibility
local leader = 'CTRL'
if wezterm.target_triple == 'x86_64-apple-darwin' or wezterm.target_triple == 'aarch64-apple-darwin' then
  leader = 'CMD'
end

config.keys = {
  -- ==== PANE MANAGEMENT ====
  -- Pane splitting (intuitive: | for vertical split, - for horizontal split)
  {
    key = '\\',
    mods = leader,
    action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
  },
  {
    key = '-',
    mods = leader,
    action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
  },

  -- Pane navigation with vim-like hjkl
  {
    key = 'h',
    mods = leader,
    action = wezterm.action.ActivatePaneDirection 'Left',
  },
  {
    key = 'j',
    mods = leader,
    action = wezterm.action.ActivatePaneDirection 'Down',
  },
  {
    key = 'k',
    mods = leader,
    action = wezterm.action.ActivatePaneDirection 'Up',
  },
  {
    key = 'l',
    mods = leader,
    action = wezterm.action.ActivatePaneDirection 'Right',
  },

  -- Alternative pane navigation with arrow keys
  {
    key = 'LeftArrow',
    mods = leader,
    action = wezterm.action.ActivatePaneDirection 'Left',
  },
  {
    key = 'DownArrow',
    mods = leader,
    action = wezterm.action.ActivatePaneDirection 'Down',
  },
  {
    key = 'UpArrow',
    mods = leader,
    action = wezterm.action.ActivatePaneDirection 'Up',
  },
  {
    key = 'RightArrow',
    mods = leader,
    action = wezterm.action.ActivatePaneDirection 'Right',
  },

  -- Pane resizing with Shift + hjkl
  {
    key = 'h',
    mods = leader .. '|SHIFT',
    action = wezterm.action.AdjustPaneSize { 'Left', 5 },
  },
  {
    key = 'j',
    mods = leader .. '|SHIFT',
    action = wezterm.action.AdjustPaneSize { 'Down', 5 },
  },
  {
    key = 'k',
    mods = leader .. '|SHIFT',
    action = wezterm.action.AdjustPaneSize { 'Up', 5 },
  },
  {
    key = 'l',
    mods = leader .. '|SHIFT',
    action = wezterm.action.AdjustPaneSize { 'Right', 5 },
  },

  -- Close pane
  {
    key = 'w',
    mods = leader,
    action = wezterm.action.CloseCurrentPane { confirm = true },
  },

  -- ==== TAB MANAGEMENT ====
  -- New tab
  {
    key = 't',
    mods = leader,
    action = wezterm.action.SpawnTab 'CurrentPaneDomain',
  },
  
  -- Tab navigator
  {
    key = 't',
    mods = leader .. '|SHIFT',
    action = wezterm.action.ShowTabNavigator,
  },

  -- Tab navigation with numbers (1-9)
  {
    key = '1',
    mods = leader,
    action = wezterm.action.ActivateTab(0),
  },
  {
    key = '2',
    mods = leader,
    action = wezterm.action.ActivateTab(1),
  },
  {
    key = '3',
    mods = leader,
    action = wezterm.action.ActivateTab(2),
  },
  {
    key = '4',
    mods = leader,
    action = wezterm.action.ActivateTab(3),
  },
  {
    key = '5',
    mods = leader,
    action = wezterm.action.ActivateTab(4),
  },
  {
    key = '6',
    mods = leader,
    action = wezterm.action.ActivateTab(5),
  },
  {
    key = '7',
    mods = leader,
    action = wezterm.action.ActivateTab(6),
  },
  {
    key = '8',
    mods = leader,
    action = wezterm.action.ActivateTab(7),
  },
  {
    key = '9',
    mods = leader,
    action = wezterm.action.ActivateTab(8),
  },

  -- Tab navigation with Tab key (cycle through tabs)
  {
    key = 'Tab',
    mods = leader,
    action = wezterm.action.ActivateTabRelative(1),
  },
  {
    key = 'Tab',
    mods = leader .. '|SHIFT',
    action = wezterm.action.ActivateTabRelative(-1),
  },

  -- Close tab
  {
    key = 'w',
    mods = leader .. '|SHIFT',
    action = wezterm.action.CloseCurrentTab { confirm = true },
  },

  -- ==== COPY/PASTE ====
  -- Cross-platform copy/paste (Ctrl+Shift on Windows/Linux, Cmd+C/V on Mac)
  {
    key = 'c',
    mods = 'SHIFT|CTRL',
    action = wezterm.action.CopyTo 'Clipboard',
  },
  {
    key = 'v',
    mods = 'SHIFT|CTRL',
    action = wezterm.action.PasteFrom 'Clipboard',
  },
  -- Mac-style copy/paste
  {
    key = 'c',
    mods = 'CMD',
    action = wezterm.action.CopyTo 'Clipboard',
  },
  {
    key = 'v',
    mods = 'CMD',
    action = wezterm.action.PasteFrom 'Clipboard',
  },

  -- ==== SEARCH & NAVIGATION ====
  -- Search
  {
    key = 'f',
    mods = leader,
    action = wezterm.action.Search 'CurrentSelectionOrEmptyString',
  },

  -- Quick launcher / Command palette
  {
    key = 'p',
    mods = leader .. '|SHIFT',
    action = wezterm.action.ActivateCommandPalette,
  },

  -- ==== FONT SIZE ====
  -- Font size adjustment
  {
    key = '=',
    mods = leader,
    action = wezterm.action.IncreaseFontSize,
  },
  {
    key = '-',
    mods = leader .. '|SHIFT',
    action = wezterm.action.DecreaseFontSize,
  },
  {
    key = '0',
    mods = leader,
    action = wezterm.action.ResetFontSize,
  },

  -- ==== SCROLLBACK ====
  -- Scrollback navigation
  {
    key = 'u',
    mods = leader,
    action = wezterm.action.ScrollByPage(-0.5),
  },
  {
    key = 'd',
    mods = leader,
    action = wezterm.action.ScrollByPage(0.5),
  },

  -- ==== WINDOW MANAGEMENT ====
  -- New window
  {
    key = 'n',
    mods = leader .. '|SHIFT',
    action = wezterm.action.SpawnWindow,
  },

  -- Toggle fullscreen
  {
    key = 'Enter',
    mods = leader .. '|SHIFT',
    action = wezterm.action.ToggleFullScreen,
  },

  -- ==== UTILITY ====
  -- Clear screen
  {
    key = 'k',
    mods = leader .. '|SHIFT',
    action = wezterm.action.ClearScrollback 'ScrollbackAndViewport',
  },

  -- Reload configuration
  {
    key = 'r',
    mods = leader .. '|SHIFT',
    action = wezterm.action.ReloadConfiguration,
  },
}
-- and finally, return the configuration to wezterm
return config
