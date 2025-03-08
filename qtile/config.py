import os
import subprocess
from datetime import datetime
from libqtile import bar, layout, qtile, widget, hook
from libqtile.config import Click, Drag, Group, Key, Match, Screen
from libqtile.lazy import lazy
from libqtile.utils import guess_terminal

mod = "mod4"
terminal = guess_terminal()

@hook.subscribe.startup_once
def autostart():
    try:
        script = os.path.expanduser("~/.config/qtile/autostart.sh")
        subprocess.call(script)
    except Exception as e:
        logfile = os.path.expanduser("~/.local/share/qtile/qtile.log")
        with open(logfile, mode="a", encoding="utf8") as f:
            f.write(
                datetime.now().strftime("%Y-%m-%dT%H:%M") + " " + str(e) + "\n"
            )

keys = [
    # A list of available commands that can be bound to keys can be found
    # at https://docs.qtile.org/en/latest/manual/config/lazy.html
    # keycodes: https://github.com/qtile/qtile/blob/master/libqtile/backend/x11/xkeysyms.py

    # Switch between windows
    Key([mod], "h", lazy.layout.left(), desc="Move focus to left"),
    Key([mod], "l", lazy.layout.right(), desc="Move focus to right"),
    Key([mod], "j", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "k", lazy.layout.up(), desc="Move focus up"),
    Key([mod], "space", lazy.layout.next(), desc="Move window focus to other window"),
    # Move windows between left/right columns or move up/down in current stack.
    # Moving out of range in Columns layout will create new column.
    Key([mod, "shift"], "h", lazy.layout.shuffle_left(), desc="Move window to the left"),
    Key([mod, "shift"], "l", lazy.layout.shuffle_right(), desc="Move window to the right"),
    Key([mod, "shift"], "j", lazy.layout.shuffle_down(), desc="Move window down"),
    Key([mod, "shift"], "k", lazy.layout.shuffle_up(), desc="Move window up"),
    # Grow windows. If current window is on the edge of screen and direction
    # will be to screen edge - window would shrink.
    Key([mod, "control"], "h", lazy.layout.grow_left(), desc="Grow window to the left"),
    Key([mod, "control"], "l", lazy.layout.grow_right(), desc="Grow window to the right"),
    Key([mod, "control"], "j", lazy.layout.grow_down(), desc="Grow window down"),
    Key([mod, "control"], "k", lazy.layout.grow_up(), desc="Grow window up"),
    Key([mod], "n", lazy.layout.normalize(), desc="Reset all window sizes"),
    # Toggle between split and unsplit sides of stack.
    # Split = all windows displayed
    # Unsplit = 1 window displayed, like Max layout, but still with
    # multiple stack panes
    Key(
        [mod, "shift"],
        "Return",
        lazy.layout.toggle_split(),
        desc="Toggle between split and unsplit sides of stack",
    ),
    Key([mod], "Return", lazy.spawn(terminal), desc="Launch terminal"),
    # Toggle between different layouts as defined below
    Key([mod], "Tab", lazy.next_layout(), desc="Toggle between layouts"),
    Key([mod], "w", lazy.window.kill(), desc="Kill focused window"),
    Key(
        [mod],
        "f",
        lazy.window.toggle_fullscreen(),
        desc="Toggle fullscreen on the focused window",
    ),
    Key([mod], "t", lazy.window.toggle_floating(), desc="Toggle floating on the focused window"),
    Key([mod, "control"], "r", lazy.reload_config(), desc="Reload the config"),
    Key([mod, "control"], "q", lazy.shutdown(), desc="Shutdown Qtile"),
    Key([mod], "r", lazy.spawncmd(), desc="Spawn a command using a prompt widget"),

    Key(["mod1"], "space", lazy.spawn("rofi -show drun")), # alt + space
    Key(["mod1"], "Tab", lazy.spawn("rofi -show")),
    Key(["mod1"], "s", lazy.spawn("rofi -show ssh")),
    Key([mod], "s", lazy.spawn("flameshot gui -c --last-region")),

    # Media keys
    Key([], "XF86AudioLowerVolume", lazy.spawn("amixer sset Master 1%-"), desc="Lower volume"),
    Key([], "XF86AudioRaiseVolume", lazy.spawn("amixer sset Master 1%+"), desc="Raise volume"),
    Key([], "XF86AudioMute", lazy.spawn("amixer sset Master 1+ toggle"), desc="Toggle mute"),

    Key([], "XF86AudioPlay", lazy.spawn("playerctl play-pause"), desc="Toggle play/pause"),
    Key([], "XF86AudioStop", lazy.spawn("playerctl stop", desc="Stop player")),
    Key([], "XF86AudioNext", lazy.spawn("playerctl next"), desc="Skip to next"),
    Key([], "XF86AudioPrev", lazy.spawn("playerctl previous"), desc="Skip to previous"),

    # Brightness
    Key([], "XF86MonBrightnessDown", lazy.spawn("brightnessctl s 6%- -q")),
    Key([], "XF86MonBrightnessUp", lazy.spawn("brightnessctl s +6% -q")),

    Key([mod, "mod1"], "l", lazy.spawn("xsecurelock")),

    Key([mod], "colon", lazy.window.bring_to_front()),
    Key([mod], "plus", lazy.window.move_up()),
    Key([mod], "minus", lazy.window.move_down()),
]

# Add key bindings to switch VTs in Wayland.
# We can't check qtile.core.name in default config as it is loaded before qtile is started
# We therefore defer the check until the key binding is run by using .when(func=...)
for vt in range(1, 8):
    keys.append(
        Key(
            ["control", "mod1"],
            f"f{vt}",
            lazy.core.change_vt(vt).when(func=lambda: qtile.core.name == "wayland"),
            desc=f"Switch to VT{vt}",
        )
    )


groups = [Group(i) for i in "123456789"]
group_keys = [
    "ampersand",
    "eacute",
    "quotedbl",
    "apostrophe",
    "parenleft",
    "section",
    "egrave",
    "exclam",
    "ccedilla",
]

for i, key in enumerate(group_keys):
    group_name = str(i + 1)
    switch_group = Key(
        [mod], key,
        lazy.group[group_name].toscreen(),
        desc=f"Switch to group {group_name}",
    )

    move_to_group = Key(
        [mod, "shift"], key,
        lazy.window.togroup(group_name, switch_group=True),
        desc=f"Switch to & move focused window to group",
    )

    keys.extend([switch_group, move_to_group])

# for i in groups:
#     keys.extend(
#         [
#             # mod + group number = switch to group
#             Key(
#                 [mod],
#                 i.name,
#                 lazy.group[i.name].toscreen(),
#                 desc=f"Switch to group {i.name}",
#             ),
#             # mod + shift + group number = switch to & move focused window to group
#             Key(
#                 [mod, "shift"],
#                 i.name,
#                 lazy.window.togroup(i.name, switch_group=True),
#                 desc=f"Switch to & move focused window to group {i.name}",
#             ),
#             # Or, use below if you prefer not to switch to that group.
#             # # mod + shift + group number = move focused window to group
#             # Key([mod, "shift"], i.name, lazy.window.togroup(i.name),
#             #     desc="move focused window to group {}".format(i.name)),
#         ]
#     )

# for i, key in enumerate(group_keys):
#     group = str(i + 1)
#     key = Key([mod], key, lazy.group[group].toscreen(), desc=f"Switch to group {group} alternative")
#     keys.append(key)

layout_defaults = dict(
    border_width=3,
    border_normal="#434d56",
    border_focus="#3d6576"
)

layouts = [
    layout.Columns(
        **layout_defaults,
        border_focus_stack=["#d75f5f", "#8f3d3d"],
        border_on_single=True,
        margin=(8, 8, 8, 8),
        margin_on_single=(6, 6, 6, 6),
        insert_position=1,
    ),
    layout.Max(),
    # Try more layouts by unleashing below layouts.
    # layout.Stack(num_stacks=2),
    # layout.Bsp(),
    # layout.Matrix(),
    # layout.MonadTall(),
    # layout.MonadWide(),
    # layout.RatioTile(),
    # layout.Tile(),
    # layout.TreeTab(),
    layout.VerticalTile(**layout_defaults),
    # layout.Zoomy(),
]

widget_defaults = dict(
    font="Ubuntu Sans SemiBold",
    fontsize=12,
    padding=3,
    # foreground="#7d7d7d"
    foreground="#c6c6c6"
)
extension_defaults = widget_defaults.copy()

def top_bar_widgets(primary_screen: bool=False) -> list:
    block_template = '''
<span foreground="#6b6a6a">[{label}</span>{{}}
<span foreground="#6b6a6a">]</span>'''.replace("\n", "")

    first_half = [
        widget.CurrentLayout(),
        widget.GroupBox(),
        widget.Prompt(),
        widget.WindowName(foreground="#94bff3"),
        widget.Chord(
            chords_colors={
                "launch": ("#ff0000", "#ffffff"),
            },
            name_transform=lambda name: name.upper(),
        ),
    ]
    second_half = [
        widget.Memory(fmt=block_template.format(label="   Mem: "), format="{MemPercent:.1f}%"),
        widget.Volume(fmt=block_template.format(label="   Vol: ")),
        widget.Bluetooth(fmt=block_template.format(label="")),
        widget.Backlight(
            fmt=block_template.format(label="Bri: "),
            brightness_file="/sys/class/backlight/nvidia_0/brightness",
            max_brightness_file="/sys/class/backlight/nvidia_0/max_brightness",
            min_brightness=5,
            step=5,
        ),
        widget.Battery(
            fmt=block_template.format(label="Bat: "),
            format="{char}{percent:2.0%} {hour:d}:{min:02d}", # Hide wattage
            charge_char="",
            discharge_char=""),
        widget.Clock(fmt=block_template.format(label="") ,format="%a %d-%m %H:%M %p"),
    ]
    if primary_screen:
        first_half.append(widget.Systray())

    return first_half + second_half

wallpaper_path = os.path.expanduser("~/background")

screens = [
    Screen(
        top=bar.Bar(
            top_bar_widgets(),
            25,
            background="#222222",
        ),
        wallpaper=wallpaper_path,
    ),
    Screen(
        top=bar.Bar(
            top_bar_widgets(primary_screen=True),
            25,
            background="#222222",
            # border_width=[2, 0, 2, 0],  # Draw top and bottom borders
            # border_color=["ff00ff", "000000", "ff00ff", "000000"]  # Borders are magenta
        ),
        wallpaper=wallpaper_path,
        # You can uncomment this variable if you see that on X11 floating resize/moving is laggy
        # By default we handle these events delayed to already improve performance, however your system might still be struggling
        # This variable is set to None (no cap) by default, but you can set it to 60 to indicate that you limit it to 60 events per second
        # x11_drag_polling_rate = 60,
    ),
]

# Drag floating layouts.
mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(), start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]

dgroups_key_binder = None
dgroups_app_rules = []  # type: list
follow_mouse_focus = True
bring_front_click = "floating_only"
floats_kept_above = True
cursor_warp = False

floating_layout = layout.Floating(
    **layout_defaults,
    float_rules=[
        # Run the utility of `xprop` to see the wm class and name of an X client.
        *layout.Floating.default_float_rules,
        Match(wm_class="confirmreset"),  # gitk
        Match(wm_class="makebranch"),  # gitk
        Match(wm_class="maketag"),  # gitk
        Match(wm_class="ssh-askpass"),  # ssh-askpass
        Match(title="branchdialog"),  # gitk
        Match(title="pinentry"),  # GPG key password entry
        Match(title="System Monitor", wm_class="gnome-system-monitor"),
    ],
)
auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True

# If things like steam games want to auto-minimize themselves when losing
# focus, should we respect this or not?
auto_minimize = True

# When using the Wayland backend, this can be used to configure input devices.
wl_input_rules = None

# xcursor theme (string or None) and size (integer) for Wayland backend
wl_xcursor_theme = None
wl_xcursor_size = 24

# XXX: Gasp! We're lying here. In fact, nobody really uses or cares about this
# string besides java UI toolkits; you can see several discussions on the
# mailing lists, GitHub issues, and other WM documentation that suggest setting
# this string if your java app doesn't work correctly. We may as well just lie
# and say that we're a working one by default.
#
# We choose LG3D to maximize irony: it is a 3D non-reparenting WM written in
# java that happens to be on java's whitelist.
wmname = "LG3D"
