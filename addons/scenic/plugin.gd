@tool
extends EditorPlugin

var inspector_plugin: EditorInspectorPlugin

func _enable_plugin() -> void:
	add_autoload_singleton("GlobalSceneManager", "res://addons/scenic/autoloads/global_scene_manager.gd")

func _disable_plugin() -> void:
	remove_autoload_singleton("GlobalSceneManager")

func _enter_tree() -> void:
	inspector_plugin = preload("res://addons/scenic/inspector_plugin.gd").new()
	add_inspector_plugin(inspector_plugin)

func _exit_tree() -> void:
	remove_inspector_plugin(inspector_plugin)
