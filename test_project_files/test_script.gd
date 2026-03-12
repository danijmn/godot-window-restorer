## Simple test script to demonstrate functionality of the Window Restorer plugin.
extends Node


@export var window_properties_label: Label
@export var window_mode_options: OptionButton
@export var quit_button: Button

@onready var _window: Window = get_window()


func _ready() -> void:
	var _WINDOW_MODES_TO_IDS: Dictionary = {
		"WINDOWED": Window.MODE_WINDOWED,
		"MINIMIZED": Window.MODE_MINIMIZED,
		"MAXIMIZED": Window.MODE_MAXIMIZED,
		"FULLSCREEN": Window.MODE_FULLSCREEN,
		"EXCLUSIVE FULLSCREEN": Window.MODE_EXCLUSIVE_FULLSCREEN}

	for mode in _WINDOW_MODES_TO_IDS:
		window_mode_options.add_item(mode, _WINDOW_MODES_TO_IDS[mode])
	window_mode_options.selected = window_mode_options.get_item_index(_window.mode)

	window_mode_options.item_selected.connect(
	func(index: int) -> void:
		_window.mode = window_mode_options.get_item_id(index) as Window.Mode
	)

	quit_button.pressed.connect(
	func() -> void:
		# NOTE: the plugin needs a chance to intercept NOTIFICATION_WM_CLOSE_REQUEST
		# so it can save the window settings, so it is VERY IMPORTANT
		# that you propagate this notification on quit requests (instead
		# of calling get_tree().quit() immediately).
		#
		# See https://docs.godotengine.org/en/stable/tutorials/inputs/handling_quit_requests.html
		get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	)

	_update_ui()


func _notification(what: int) -> void:
	# Catch own quit button notification OR notification fired by
	# pressing the native window close button.
	# This happens AFTER the plugin has saved the window's configuration
	# (the plugin is an Autoload so it is called earlier),
	# so it's safe to quit now!
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		get_tree().quit()


func _process(_delta: float) -> void:
	_update_ui()


func _update_ui() -> void:
	if Engine.is_embedded_in_editor():
		window_properties_label.text = \
			"EMBEDDED MODE IS ENABLED. DISABLE IT AND RESTART TO TEST THE PLUGIN!"
		window_mode_options.visible = false
		quit_button.visible = false
	else:
		window_properties_label.text = \
			"""WINDOW PROPERTIES
			- Screen index: %d
			- Size: %s
			- Position: %s
			- Mode:""" \
			% [_window.current_screen, _window.size, _window.position]
		window_mode_options.selected = _window.mode
		window_mode_options.visible = true
		quit_button.visible = true
