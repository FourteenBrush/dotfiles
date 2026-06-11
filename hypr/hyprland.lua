--------------------
-- MONITORS
--------------------

-- transform: 0 = normal, 1 = 90 degrees, 2 = 180 degrees, 3 = 270 degrees

-- horizontal layout
hl.monitor { output = "eDP-1", position = "2560x0", scale = 1 }
hl.monitor { output = "DP-2", mode =  "2560x1440@180", position = "0x0", scale = 1 }

hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })

--------------------
-- AUTOSTART
--------------------

-- NOTE: no need for & disown
hl.on("hyprland.start", function ()
  -- hl.exec_cmd("waybar")
  hl.exec_cmd("qs -c noctalia-shell 2>&1 > ~/Software/quickshell/log.txt")
  hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-theme phinger-cursors-light")
  hl.exec_cmd("systemctl --user start hyprpolkitagent")

  hl.exec_cmd("gsettings set org.gnome.desktop.interface color-scheme \"prefer-dark\"")
  hl.exec_cmd("gsettings set org.gnome.desktop.interface gtk-theme \"Adwaita\"")
  -- hl.exec_cmd("blueman-applet")
  hl.exec_cmd("netbird-ui")
end)

--------------------
-- ENVIRONMENT
--------------------

local cursor_size, cursor_theme = 24, "phinger-cursors-dark"
hl.env("XCURSOR_SIZE", cursor_size)
hl.env("HYPRCURSOR_SIZE", cursor_size)
-- see .icons folder
hl.env("XCURSOR_THEME", cursor_theme)
hl.env("HYPRCURSOR_THEME", cursor_theme)

-- hardware accel
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("QT_QPA_PLATFORM", "wayland")

--------------------
-- LOOK AND FEEL
--------------------

hl.config {
  debug = { disable_logs = true },

  general = {
    gaps_in = 6,
    gaps_out = { top = 8, right = 10, bottom = 10, left = 10 },
    border_size = 2,
    col = {
      active_border = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
      inactive_border = "rgba(595959aa)",
    },
    -- controls resizing of windows by dragging the border
    resize_on_border = false,
    allow_tearing = false,
    layout = "dwindle",
  },

  decoration = {
    rounding = 10,
    rounding_power = 2,

    -- change transparency of focused and unfocused windows
    active_opacity = 1.0,
    inactive_opacity = 1.0,
    shadow = {
      enabled = true,
      range = 4,
      render_power = 3,
      color = "rgba(1a1a1aee)",
    },
    blur = {
      enabled = true,
      size = 3,
      passes = 1,
      vibrancy = 0.1696,
    },
  },

  master = {
    -- new window becomes..
    new_status = "slave",
    -- default placement of master area
    orientation = "left",
  },

  dwindle = {
    preserve_split = true,
    force_split = 2, -- new split to the right
  },

  misc = {
    force_default_wallpaper = 0,
    disable_hyprland_logo = true,
    -- disable dialog for unresponsive applications, most of the time they are actually
    -- responding but glfw isnt't handling the xdg_wm_base::ping event correctly or something
    enable_anr_dialog = false,
  },
}

--------------------
-- ANIMATIONS
--------------------

hl.curve("easeOutQuint", { type = "bezier", points = { {0.23, 1}, {0.32, 1} } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1} } })
hl.curve("linear", { type = "bezier", points = { {0, 0}, {1, 1} } })
hl.curve("almostLinear", { type = "bezier", points = { {0.5, 0.5}, {0.75, 1.0} } })
hl.curve("quick", { type = "bezier", points = { {0.15, 0}, {0.1, 1} } })

hl.animation({ leaf = "global",        enabled = true, speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 4.1,  bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 1.5,  bezier = "linear", style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })

--------------------
-- WORKSPACE/WINDOW RULES
--------------------

for id = 1, 5 do
  hl.workspace_rule { workspace = tostring(id), monitor = "eDP-1" }
end
for id = 6, 10 do
  hl.workspace_rule { workspace = tostring(id), monitor = "DP-2" }
end

hl.window_rule {
  float = false,
  match = {
    class = "XTerm",
    title = "xdg-su: /sbin/yast.*",
  },
}

-- blueman-applet
hl.window_rule { float = true, match = { class = "blueman-manager", title = "Bluetooth Devices" } }
hl.window_rule { float = true, match = { class = "blueman-services"} }

hl.window_rule { float = true, match = { class = "nwg-displays" } }
hl.window_rule { float = true, match = { class = "zen", title = "Picture-in-Picture" } }
hl.window_rule { float = true, size = { 800, 500 },  match = { class = "zen", title = "Sign in - Google Accounts.*" } }
hl.window_rule { float = true, match = { class = "org.quickshell", title = "Noctalia" } }

-- ignore maximize requests from apps
hl.window_rule { suppress_event = "maximize", match = { class = ".*" }  }
-- fix some dragging issues with xwayland
hl.window_rule {
  no_focus = true,
  match = {
    class      = "^$",
    title      = "^$",
    xwayland   = true,
    float      = true,
    fullscreen = false,
    pin        = false,
  },
}

--------------------
-- KEYBINDS
--------------------

hl.bind("SUPER + RETURN", hl.dsp.exec_cmd("kitty"))
hl.bind("ALT + SPACE", hl.dsp.exec_cmd("rofi -show drun"))
hl.bind("SUPER + E", hl.dsp.exec_cmd("nautilus"))
hl.bind("SUPER + ALT + L", hl.dsp.exec_cmd("hyprlock"))
-- hyprshot freeze requires hyprpicker
hl.bind("SUPER + S", hl.dsp.exec_cmd("hyprshot -m region --clipboard-only -t 2000 --freeze"))

hl.bind("SUPER + W", hl.dsp.window.close())
hl.bind("SUPER + SHIFT + W", hl.dsp.window.kill()) -- sends SIGKILL
hl.bind("SUPER + T", hl.dsp.window.float()) -- togglefloat
hl.bind("SUPER + P", hl.dsp.window.pseudo())
hl.bind("SUPER + F", hl.dsp.window.fullscreen())

-- move focus with hjkl keys, when combined with shift, moves the window
for key, dir in pairs({h = "l", l = "r", k = "u", j = "d"}) do
  hl.bind("SUPER +" .. key, hl.dsp.focus { direction = dir })
  hl.bind("SUPER + SHIFT +" .. key, hl.dsp.window.move { direction = dir })
end

local workspace_keysyms = {
  "ampersand", "eacute", "quotedbl", "apostrophe", "parenleft",
  "section", "egrave", "exclam", "ccedilla", "agrave",
}
for workspace, keysym in ipairs(workspace_keysyms) do
  -- switch workspaces with mainmod + [0-9]
  hl.bind("SUPER +" .. keysym, hl.dsp.focus { workspace = workspace })
  -- move active window to a workspace with mainmod + SHIFT + [0-9]
  hl.bind("SUPER + SHIFT +" .. keysym, hl.dsp.window.move { workspace = workspace })
end

-- special workspace
hl.bind("SUPER + M", hl.dsp.workspace.toggle_special("magic"))
hl.bind("SUPER + SHIFT + M", hl.dsp.window.move { workspace = "special:magic" })

-- scroll through existing workspaces
hl.bind("SUPER + mouse_down", hl.dsp.focus { workspace = "e-1" })
hl.bind("SUPER + mouse_up", hl.dsp.focus { workspace = "e+1" })

-- move/resize with mainmod + LMB/RMB and dragging
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- laptop multimedia keys
local media_prev_cmd = "playerctl previous"
local media_next_cmd = "playerctl next"
local media_play_pause_cmd = "playerctl play-pause"
local media_audio_mute_toggle = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
local media_lower_volume = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-"
local media_raise_volume = "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 2%+"

local multimedia_binds = {
  { "XF86AudioMute",         media_audio_mute_toggle },
  { "XF86AudioLowerVolume",  media_lower_volume,                            { repeating = true } },
  { "XF86AudioRaiseVolume",  media_raise_volume,                            { repeating = true } },
  { "XF86AudioMicMute",      "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle" },
  { "XF86MonBrightnessDown", "brightnessctl s 10%-",                        { repeating = true } },
  { "XF86MonBrightnessUp",   "brightnessctl s 10%+",                        { repeating = true } },

  { "XF86AudioPlay",  media_play_pause_cmd, { ignore_mods = true } },
  { "XF86AudioPause", media_play_pause_cmd, { ignore_mods = true } },
  { "XF86AudioPrev",  media_prev_cmd,       { ignore_mods = true } },
  { "XF86AudioNext",  media_next_cmd,       { ignore_mods = true } },
}
for _, bind in ipairs(multimedia_binds) do
  local key, cmd, opts = bind[1], bind[2], bind[3] or {}
  hl.bind(key, hl.dsp.exec_cmd(cmd), {
    locked = true,
    repeating = opts.repeating or false,
    ignore_mods = opts.ignore_mods or false,
  })
end

-- only enable the following keybinds when used on the specified device
local multimedia_logitech = {
  -- logitech g413
  { "F6",  media_prev_cmd },
  { "F7",  media_play_pause_cmd },
  { "F8",  media_next_cmd },
  { "F9",  media_audio_mute_toggle },
  { "F10", media_lower_volume },
  { "F11", media_raise_volume },
}
for _, bind in ipairs(multimedia_logitech) do
  local key, cmd = bind[1], bind[2]
  hl.bind(key, hl.dsp.exec_cmd(cmd), {
    locked = true,
    repeating = true,
    device = { list = { "logitech-logig-mkeyboard" } },
  })
end

-- cycle layouts
hl.bind("SUPER + TAB", function ()
  local layouts = { "dwindle", "master" }
  local workspace = hl.get_active_workspace()
  if not workspace then return end

  local next_layout = "dwindle"
  for i = 1, #layouts do
    if layouts[i] == workspace.tiled_layout then
      next_layout = layouts[(i % #layouts) + 1]
      break
    end
  end

  hl.workspace_rule { workspace = workspace.name, layout = next_layout }
  -- https://wiki.hypr.land/Configuring/Advanced-and-Cool/Using-hyprctl/#notify
  hl.notification.create { text = "Switched layout to " .. next_layout, timeout = 950, icon = "hint", color = "#A9D84C" }
end)

--------------------
-- GESTURES
--------------------

hl.config {
  gestures = {
    workspace_swipe_touch = true,
  },
}
hl.gesture { fingers = 3, direction = "horizontal", action = "workspace" }

hl.config {
  input = {
    kb_layout = "be",
    kb_options = "",

    -- change focus to window under cursor
    follow_mouse = 1,
    -- value between -1 to 1, 0 means no modification at all
    sensitivity = 0,
    touchpad = {
      natural_scroll = true,
    },
  },
}
