local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.color_scheme = "Noctalia"
config.colors = {
  background = "#282828",
}

config.font = wezterm.font {
  family = "Jetbrains Mono NF Medium",
  harfbuzz_features = { "cv24" },
}
config.font_size = 11

-- looks better on hyprland
-- defaults = 1cell left & right, 0.5cell top and bottom
config.window_padding = {
  left = 1,
  right = 1,
  top = 1,
  bottom = 1,
}

config.tab_bar_at_bottom = true
config.hide_tab_bar_if_only_one_tab = true

config.alternate_buffer_wheel_scroll_speed = 1

return config
