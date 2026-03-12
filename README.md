# Godot window restore plugin
This runtime plugin persists window configuration (screen, mode, 
size and position) to disk, and restores that configuration when
the application is restarted.

# Why?
Preserving window size and position is a basic functionality of any modern
desktop application, and games are no exception.
Since Godot 4.4, the editor window is automatically restored.
Unfortunately, this functionality is not available for exported
projects (as of Godot 4.6). This plugin addresses that limitation.

# Verified Godot versions
4.4, 4.5 and 4.6.

# Installation
Copy to your project's `addons` folder, then enable the plugin
in `Project Settings > Plugins` ("Window Configuration Restorer").
The plugin registers itself automatically as an Autoload on import.

# Features
- Sanitizes window screen, size and position according to current display
capabilities.
- Properly accounts for the possibility of closing the application while the
window is minimized (saves settings from the last time the window was open).
- Only runs on desktop platforms, and does not interfere with window embedding
within the editor (introduced in Godot 4.4).

# Limitations
The window can only be restored after the boot splash is displayed.
This is an inherent limitation of Godot plugins, i.e. you can't run
code before Godot's runtime is loaded. This means that if the last window mode
is different from the project setting `display/window/size/mode`, the player
will see transition when starting the game.

For example, if the project setting is `Fullscreen` but the last window
mode set at runtime by the player was a maximized window, during the next run,
the player will see the boot splash in a fullscreen window,
followed by a transition to a maximized window.

This transition should happen very quickly, so it's not likely to be a
problem for your users. Therefore, in most cases, I recommend you simply set
`display/window/size/mode` to whichever mode makes most sense for your project
by default (usually `Fullscreen` for games and `Windowed` for
non-game applications).
