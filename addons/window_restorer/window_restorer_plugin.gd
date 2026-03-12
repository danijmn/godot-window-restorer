## Implements logic of the Window Restorer plugin.
extends Node


## The path of the ConfigFile where the window settings will be saved.
const _FILE_PATH: String = "user://display.cfg"

## The section within the ConfigFile where the window settings will be saved.
const _WINDOW_SECTION_ID: String = "Window"

var _is_non_pc_platform: bool = !OS.has_feature("pc")
var _last_mode_except_minimized: Window.Mode

@onready var _window: Window = get_tree().root


func _ready() -> void:
	if _is_non_pc_platform || Engine.is_embedded_in_editor():
		return

	_load_window_settings()
	if _window.mode != Window.MODE_MINIMIZED:
		_last_mode_except_minimized = _window.mode


func _notification(what: int) -> void:
	if _is_non_pc_platform || Engine.is_embedded_in_editor():
		return

	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_save_window_settings()


func _process(_delta: float) -> void:
	if _is_non_pc_platform || Engine.is_embedded_in_editor():
		return

	if _window.mode != Window.MODE_MINIMIZED:
		_last_mode_except_minimized = _window.mode


func _load_window_settings() -> void:
	if _is_non_pc_platform || Engine.is_embedded_in_editor():
		return

	var config = ConfigFile.new()
	if config.load(_FILE_PATH) != OK:
		return
	if !config.has_section(_WINDOW_SECTION_ID):
		return

	# Obtain and sanitize the last used screen,
	# then move window to that screen (if different from current)
	var stored_screen = config.get_value(_WINDOW_SECTION_ID, "screen", "N/A")
	if stored_screen is int && _window.current_screen != stored_screen && \
	   stored_screen >= 0 && stored_screen < DisplayServer.get_screen_count():
		_window.current_screen = stored_screen

	# Obtain stored last window mode (default to current mode if not valid)
	var stored_mode = config.get_value(_WINDOW_SECTION_ID, "mode", "N/A")
	if stored_mode is not Window.Mode:
		stored_mode = _window.mode
	match stored_mode:
		Window.MODE_MAXIMIZED, Window.MODE_FULLSCREEN, Window.MODE_EXCLUSIVE_FULLSCREEN:
			# If the last window mode is maximized/fullscreen,
			# just restore it (if different from current)
			if _window.mode != stored_mode:
				_window.mode = stored_mode
		Window.MODE_WINDOWED:
			# If the last window mode is "windowed", we also need to obtain,
			# sanitize and restore the window's last size and position
			var usable_rect: Rect2i = DisplayServer.screen_get_usable_rect(_window.current_screen)
			var stored_size = config.get_value(_WINDOW_SECTION_ID, "size", "N/A")
			if stored_size is not Vector2i:
				stored_size = _window.size

			if stored_size.x > usable_rect.size.x && stored_size.y > usable_rect.size.y && \
			   stored_size.x >= _window.min_size.x && stored_size.y >= _window.min_size.y:
				# The window's size exceeds the desktop's usable rect -> just maximize the window
				# (provided the minimum window size is respected)
				if _window.mode != Window.MODE_MAXIMIZED:
					_window.mode = Window.MODE_MAXIMIZED
			else:
				if _window.mode != Window.MODE_WINDOWED:
					_window.mode = Window.MODE_WINDOWED

				var stored_position = config.get_value(_WINDOW_SECTION_ID, "position", "N/A")
				if stored_position is not Vector2i:
					stored_position = _window.position

				# Size and position sanitation and restoration
				var safe_end: Vector2i = usable_rect.end.min(stored_position + stored_size)
				var safe_position: Vector2i = usable_rect.position.max(safe_end - stored_size)
				var safe_size: Vector2i = _window.min_size.max(safe_end - safe_position)
				if _window.position != safe_position:
					_window.position = safe_position
				if _window.size != safe_size:
					_window.size = safe_size


func _save_window_settings() -> void:
	if _is_non_pc_platform || Engine.is_embedded_in_editor():
		return

	var config = ConfigFile.new()
	config.set_value(_WINDOW_SECTION_ID, "screen", _window.current_screen)
	if _window.mode != Window.MODE_MINIMIZED:
		config.set_value(_WINDOW_SECTION_ID, "mode", _window.mode)
	else:
		config.set_value(_WINDOW_SECTION_ID, "mode", _last_mode_except_minimized)
	config.set_value(_WINDOW_SECTION_ID, "size", _window.size)
	config.set_value(_WINDOW_SECTION_ID, "position", _window.position)
	config.save(_FILE_PATH)
