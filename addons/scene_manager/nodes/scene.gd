@icon("res://addons/scene_manager/icons/clapperboard.svg")
class_name Scene extends Node

#region exports
# Used to set tags in the inspector, not to be used at runtime
@export var _tags: Array[String] = []

#region identity
var _internal_tags: Dictionary = {}

#region references
var scene_manager: SceneManager = null

#region node_events
func _enter_tree() -> void:
	for tag in _tags:
		_internal_tags.set(tag, null)

#region public_functions
func add_tag(tag: String) -> void:
	_internal_tags.set(tag, null)

func remove_tag(tag: String) -> void:
	_internal_tags.erase(tag)

func has_tag(tag: String) -> bool:
	return _internal_tags.has(tag)

func get_tags() -> Array[String]:
	return _internal_tags.keys()
