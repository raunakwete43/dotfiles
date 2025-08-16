import os
import subprocess

# from qtile_extras import widget as widgetex
from libqtile import bar, hook, layout, qtile, widget
from libqtile.config import Click, Drag, Group, Key, Match, Screen, ScratchPad, DropDown
from libqtile.lazy import lazy

import colors

mod = "mod4"
terminal = "kitty"
app_menu = "./.config/rofi/scripts/launcher_t1"
logout = "./.config/rofi/scripts/powermenu_t1"

(
    colors,
    backgroundColor,
    foregroundColor,
    workspaceColor,
    chordColor,
) = colors.catppuccin()


@hook.subscribe.startup_once
def autostart():
    script = os.path.expanduser("~/.config/qtile/autostart.sh")
    subprocess.run([script])


keys = [
    # A list of available commands that can be bound to keys can be found
    # at https://docs.qtile.org/en/latest/manual/config/lazy.html
    # Switch between windows
    Key([mod], "h", lazy.layout.left(), desc="Move focus to left"),
    Key([mod], "l", lazy.layout.right(), desc="Move focus to right"),
    Key([mod], "j", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "k", lazy.layout.up(), desc="Move focus up"),
    Key([mod], "space", lazy.layout.next(), desc="Move window focus to other window"),
    # Move windows between left/right columns or move up/down in current stack.
    # Moving out of range in Columns layout will create new column.
    Key(
        [mod, "control"],
        "j",
        lazy.layout.grow_down(),
        lazy.layout.shrink(),
        desc="Grow window down",
    ),
    Key(
        [mod, "control"],
        "k",
        lazy.layout.grow_up(),
        lazy.layout.grow(),
        desc="Grow window up",
    ),
    # Resize Windows
    Key(
        [mod, "control"],
        "l",
        lazy.layout.grow_right(),
        lazy.layout.grow(),
        lazy.layout.increase_ratio(),
        lazy.layout.delete(),
    ),
    Key(
        [mod, "control"],
        "h",
        lazy.layout.grow_left(),
        lazy.layout.shrink(),
        lazy.layout.decrease_ratio(),
        lazy.layout.add(),
    ),
    Key([mod, "control"], "r", lazy.layout.reset()),
    # MOVE WINDOWS UP OR DOWN MONADTALL/MONADWIDE LAYOUT
    Key([mod, "shift"], "k", lazy.layout.shuffle_up()),
    Key([mod, "shift"], "j", lazy.layout.shuffle_down()),
    Key([mod, "shift"], "h", lazy.layout.swap_left()),
    Key([mod, "shift"], "l", lazy.layout.swap_right()),
    Key([mod], "Tab", lazy.screen.toggle_group()),
    Key(["mod1"], "Tab", lazy.layout.down()),
    Key(["mod1", "shift"], "Tab", lazy.layout.up()),
    # Key([mod], "e", lazy.layout.maximize()),
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
    Key([mod, "control"], "Tab", lazy.next_layout(), desc="Toggle between layouts"),
    Key([mod], "q", lazy.window.kill(), desc="Kill focused window"),
    Key(
        [mod],
        "f",
        lazy.window.toggle_fullscreen(),
        desc="Toggle fullscreen on the focused window",
    ),
    Key(
        [mod],
        "t",
        lazy.window.toggle_floating(),
        desc="Toggle floating on the focused window",
    ),
    Key([mod, "shift"], "r", lazy.reload_config(), desc="Reload the config"),
    Key([mod, "control"], "q", lazy.shutdown(), desc="Shutdown Qtile"),
    Key(
        [mod],
        "d",
        lazy.spawn("xfce4-appfinder"),
        desc="Spawn a command using a prompt widget",
    ),
    Key(
        [mod],
        "w",
        lazy.spawn("brave --password-store=kwallet6"),
        desc="Spawn Brave Browser",
    ),
    Key([], "XF86AudioRaiseVolume", lazy.spawn("amixer set Master 2%+")),
    Key([], "XF86AudioLowerVolume", lazy.spawn("amixer set Master 2%-")),
    Key([], "XF86AudioMute", lazy.spawn("amixer set Master 1+ toggle")),
    Key([mod], "p", lazy.spawn("brightnessctl s 5%+")),
    Key([mod], "o", lazy.spawn("brightnessctl s 5%-")),
    Key([mod, "shift"], "Return", lazy.spawn("thunar")),
    Key(
        ["control", "mod1"],
        "o",
        lazy.spawn("./.config/arco-chadwm/scripts/picom-toggle.sh"),
    ),
]


# Create labels for groups and assign them a default layout.
groups = []


group_names = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]

group_labels = ["", "", "", "", "", "󰓇", "", "", ""]
# group_labels = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"]

group_layouts = [
    "monadtall",
    "max",
    "max",
    "max",
    "monadtall",
    "max",
    "monadtall",
    "monadtall",
    "monadtall",
]

group_matches = [
    None,
    [Match(wm_class=["Brave-browser"])],
    [
        Match(
            wm_class=[
                "Pcmanfm",
                "Thunar",
                "dolphin",
                "Caja",
                "Catfish",
            ]
        )
    ],
    [
        Match(
            wm_class=[
                "Code",
                "VSCodium",
                "neovide",
                "jetbrains-pycharm",
                "jetbrains-idea-ce",
                "jetbrains-studio",
                "jetbrains-rustrover",
                "jetbrains-clion-nova",
                "code - insiders",
                "dev.zed.Zed",
            ]
        )
    ],
    [Match(wm_class=["vlc"])],
    [Match(wm_class=["open.spotify.com", "Spotify", "spotube", "Spotube"])],
    None,
    None,
    [Match(wm_class=["qbittorrent"])],
]


# Add group names, labels, and default layouts to the groups object.
for i in range(len(group_names)):
    groups.append(
        Group(
            name=group_names[i],
            layout=group_layouts[i].lower(),
            label=group_labels[i],
            matches=group_matches[i],
        )
    )


# Add group specific keybindings
for i in groups:
    keys.extend(
        [
            Key(
                [mod],
                i.name,
                lazy.group[i.name].toscreen(),
                desc="Mod + number to move to that group.",
            ),
            # Key(["mod1"], "Tab", lazy.screen.next_group(),
            #     desc="Move to next group."),
            # Key(["mod1", "shift"], "Tab", lazy.screen.prev_group(),
            #     desc="Move to previous group."),
            Key(
                [mod, "shift"],
                i.name,
                lazy.window.togroup(i.name),
                desc="Move focused window to new group.",
            ),
        ]
    )


### LAYOUTS ###
# Some settings that I use on almost every layout, which saves us
# from having to type these out for each individual layout.
layout_theme = {
    "margin": 6,
    "border_width": 2,
    "border_focus": colors[2],
    "border_normal": backgroundColor,
}
layouts = [
    layout.MonadTall(**layout_theme),
    # layout.MonadWide(**layout_theme),
    layout.Floating(**layout_theme),
    # layout.RatioTile(**layout_theme),
    layout.Max(**layout_theme),
]


widget_defaults = dict(
    font="JetBrainsMono Nerd Font",
    fontsize=12,
    padding=3,
)
extension_defaults = widget_defaults.copy()


widgets_list = [
    # widget.TextBox(
    #     text="  ", fontsize=18,
    #     font="JetBrainsMono Nerd Font", foreground=colors[8],
    #     mouse_callbacks={'Button1': lambda: qtile.cmd_spawn("xfce4-appfinder")}
    # ),
    widget.GroupBox(
        font="JetBrainsMono Nerd Font",
        fontsize=13,
        padding=8,
        margin_x=4,
        active=colors[7],
        highlight_method="line",
        highlight_color=[backgroundColor, backgroundColor],
        this_current_screen_border=colors[5],
        this_screen_border=colors[7],
        other_screen_border=colors[6],
        borderwidth=2,
        use_mouse_wheel=False,
        disable_drag=True,
    ),
    widget.Sep(linewidth=1, padding=10, foreground=colors[2]),
    widget.CurrentLayoutIcon(scale=0.5, foreground=colors[4]),
    widget.Sep(linewidth=1, padding=10, foreground=colors[2]),
    # widget.Prompt(),
    widget.WindowCount(
        text_format="[{num}]",
        foreground=colors[7],
        font="JetBrainsMono Nerd Font",
        fontsize=14,
    ),
    # widget.WindowName(),
    widget.TaskList(
        highlight_method="border",
        borderwidth=1,
        border=colors[0],
        font="JetBrainsMono Nerd Font",
        fontsize=12,
        icon_size=14,
        padding=3,
        spacing=4,
        rounded=True,
        txt_minimized="- ",
    ),
    widget.TextBox(
        text="   ",
        fontsize=14,
        font="JetBrainsMono Nerd Font",
        foreground=colors[7],
    ),
    widget.Battery(
        format="{percent:2.0%}",
    ),
    widget.Spacer(length=10),
    widget.TextBox(
        text=" ", fontsize=14, font="JetBrainsMono Nerd Font", foreground=colors[4]
    ),
    widget.Backlight(
        backlight_name="amdgpu_bl1",
        mouse_callbacks={
            "Button1": lambda: subprocess.run(["brightnessctl", "s", "30%"]),
            "Button4": lambda: subprocess.run(["brightnessctl", "s", "1%+"]),
            "Button5": lambda: subprocess.run(["brightnessctl", "s", "1%-"]),
        },
    ),
    widget.Sep(linewidth=0, padding=10, foreground=colors[5]),
    widget.TextBox(
        text=" ", fontsize=14, font="JetBrainsMono Nerd Font", foreground=colors[10]
    ),
    widget.ThermalSensor(
        threshold=80,
        mouse_callbacks={"Button1": lambda: qtile.cmd_spawn("st -c btop -e btop")},
    ),
    widget.Sep(linewidth=0, padding=10, foreground=colors[5]),
    widget.TextBox(
        text=" ", fontsize=14, font="JetBrainsMono Nerd Font", foreground=colors[7]
    ),
    widget.CPU(
        font="JetBrainsMono Nerd Font",
        update_interval=1.0,
        format="{load_percent}%",
        foreground=foregroundColor,
        padding=5,
        mouse_callbacks={"Button1": lambda: qtile.cmd_spawn("st -c btop -e btop")},
    ),
    widget.Sep(linewidth=0, padding=10),
    widget.TextBox(
        text="", fontsize=14, font="JetBrainsMono Nerd Font", foreground=colors[3]
    ),
    widget.Memory(
        font="JetBrainsMonoNerdFont",
        foreground=foregroundColor,
        format="{MemUsed: .0f}{mm} /{MemTotal: .0f}{mm}",
        measure_mem="G",
        padding=5,
        mouse_callbacks={"Button1": lambda: qtile.cmd_spawn("st -c btop -e btop")},
    ),
    widget.Sep(linewidth=0, padding=10),
    widget.TextBox(
        text=" ", fontsize=14, font="JetBrainsMono Nerd Font", foreground=colors[6]
    ),
    widget.Volume(
        font="JetBrainsMono Nerd Font",
        volume_app="st -c alsamixer -g 70x20 -e alsamixer",
        mouse_callbacks={
            "Button1": lambda: qtile.cmd_spawn("amixer set Master 1+ toggle")
        },
    ),
    widget.Spacer(length=10),
    widget.Net(
        interface="wlan0",
        format="{down:.0f}{down_suffix} ↓↑ {up:.0f}{up_suffix}",
        foreground=colors[7],
        update_interval=1,
        prefix="M",
    ),
    widget.Sep(linewidth=0, padding=10),
    widget.TextBox(
        text=" ", fontsize=14, font="JetBrainsMono Nerd Font", foreground=colors[6]
    ),
    widget.Wlan(
        use_ethernet=True,
        interface="wlan0",
        ethernet_interface="enp3s0f3u4",
        # format="{essid} {percent:5.0%}",
        update_interval=5,
        format="{essid}",
        mouse_callbacks={
            "Button1": lambda: qtile.cmd_spawn("networkmanager_dmenu"),
        },
    ),
    widget.Sep(linewidth=0, padding=10),
    widget.TextBox(
        text=" ", fontsize=14, font="JetBrainsMono Nerd Font", foreground=colors[10]
    ),
    widget.Clock(
        # format="%a %d/%m/%y %I:%M %p",
        format="%a %e %b %I:%M %p",
        font="JetBrainsMono Nerd Font",
        fontsize=12,
        padding=1,
        foreground=foregroundColor,
        mouse_callbacks={
            "Button1": lambda: qtile.cmd_spawn("./Downloads/scripts/calendar.sh")
        },
    ),
    widget.Spacer(length=10),
    widget.Systray(icon_size=22, padding=4),
    widget.Spacer(length=10),
    widget.TextBox(
        text=" ",
        fontsize=18,
        font="JetBrainsMono Nerd Font",
        foreground=colors[9],
        mouse_callbacks={"Button1": lambda: qtile.cmd_spawn(logout)},
    ),
]

screens = [
    Screen(
        wallpaper="~/Pictures/Wallpaper/wallpaperflare.com_wallpaper.jpg",
        wallpaper_mode="fill",
        top=bar.Bar(
            widgets=widgets_list,
            size=30,
            background="#00000000",
            margin=5,
        ),
    ),
    Screen(
        wallpaper="~/Pictures/Wallpaper/wallpaperflare.com_wallpaper.jpg",
        wallpaper_mode="fill",
    ),
]

# Drag floating layouts.
mouse = [
    Drag(
        [mod],
        "Button1",
        lazy.window.set_position_floating(),
        start=lazy.window.get_position(),
    ),
    Drag(
        [mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()
    ),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]

dgroups_key_binder = None
dgroups_app_rules = []  # type: list
follow_mouse_focus = True
bring_front_click = False
floats_kept_above = True
cursor_warp = False
floating_layout = layout.Floating(
    **layout_theme,
    float_rules=[
        # Run the utility of `xprop` to see the wm class and name of an X client.
        *layout.Floating.default_float_rules,
        Match(wm_class="confirmreset"),  # gitk
        Match(wm_class="makebranch"),  # gitk
        Match(wm_class="maketag"),  # gitk
        Match(wm_class="ssh-askpass"),  # ssh-askpass
        Match(wm_class="xfce4-appfinder"),
        Match(wm_class="gnome-calendar"),
        Match(title="branchdialog"),  # gitk
        Match(title="Pinentry-gtk"),  # GPG key password entry
        Match(wm_class="btop"),
        Match(wm_class="alsamixer"),
        Match(wm_class="blueberry.py"),
        Match(wm_class="mpv"),
        Match(wm_class="matplotlib"),
        Match(wm_class="Tk"),
        Match(wm_class="Calculator"),
        Match(wm_class="gnome-calculator"),
        Match(wm_class="qbittorrent"),
        Match(wm_class="pinentry-gtk"),
        Match(wm_class="nm-connection-editor"),
        Match(wm_class="pavucontrol"),
        Match(wm_class="mpv"),
        Match(wm_class="gl"),
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

# XXX: Gasp! We're lying here. In fact, nobody really uses or cares about this
# string besides java UI toolkits; you can see several discussions on the
# mailing lists, GitHub issues, and other WM documentation that suggest setting
# this string if your java app doesn't work correctly. We may as well just lie
# and say that we're a working one by default.
#
# We choose LG3D to maximize irony: it is a 3D non-reparenting WM written in
# java that happens to be on java's whitelist.
wmname = "LG3D"
