## Registers the Window Restorer plugin as an Autoload.
@tool
extends EditorPlugin


const _AUTOLOAD_NAME = "WindowRestorerPlugin"


func _enable_plugin():
	add_autoload_singleton(_AUTOLOAD_NAME, "window_restorer_plugin.gd")


func _disable_plugin():
	remove_autoload_singleton(_AUTOLOAD_NAME)
