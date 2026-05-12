hl.env("GTK_THEME", "Sweet-Dark-v40")
hl.env("XCURSOR_THEME", "Sweet-cursors")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "32")

-- --- Wayland / session ---
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

-- --- Backends ---
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("QT_QPA_PLATFORM", "wayland")
hl.env("SDL_VIDEODRIVER", "wayland")
hl.env("CLUTTER_BACKEND", "wayland")

-- --- Qt ---
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "0")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")

-- Optional qt5ct theming
hl.env("QT_QPA_PLATFORMTHEME", "qt5ct")

-- --- Electron / Chromium ---
hl.env("OZONE_PLATFORM", "wayland")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
