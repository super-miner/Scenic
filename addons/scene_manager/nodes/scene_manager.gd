@icon("res://addons/scene_manager/icons/layers.svg")
class_name SceneManager extends Node

#region constants
const INCORRECT_TYPE_WARNING: String = "[Scenes] Provided scene is not is not of type Scene"

#region exports
@export var global: bool = true
@export var _initial_scenes: Array[PackedScene] = []

#region references
var _scene_parent: Node = null
var _active_scenes: Dictionary = {}
var _transitions: Dictionary = {}

#region node_events
func _ready() -> void:
	_create_scene_parent()
	
	if global:
		GlobalSceneManager.register_scene_manager(self)
	
	remove_scenes()
	for scene in _initial_scenes:
		add_scene(scene)

func _exit_tree() -> void:
	if global:
		GlobalSceneManager.unregister_scene_manager(self)

#region public_functions
func add_scene(scene_scene: PackedScene) -> void:
	var scene = scene_scene.instantiate()
	
	if scene is not Scene:
		push_warning(INCORRECT_TYPE_WARNING)
		return
	
	scene.scene_manager = self
	
	_scene_parent.add_child(scene)
	_active_scenes.set(scene, null)

func remove_scene(scene: Scene) -> void:
	scene.queue_free()
	_scene_parent.remove_child(scene)
	_active_scenes.erase(scene)

func remove_scenes(exclude_tags: Array[String] = []) -> void:
	for scene in _active_scenes:
		var should_remove = true
		for tag in exclude_tags:
			if scene.has_tag(tag):
				should_remove = false
				break
		
		if should_remove:
			scene.queue_free()
			_scene_parent.remove_child(scene)
	
	_active_scenes = {}

func set_scene(scene_scene: PackedScene, exclude_tags: Array[String] = []) -> void:
	remove_scenes(exclude_tags)
	add_scene(scene_scene)

func with_transition(callback: Callable, in_transition: StringName, in_time_scale: float = 1.0, out_transition: StringName = &"", out_time_scale: float = -1.0) -> void:
	var transition = _get_transition_by_name(in_transition)
	var time_scale = in_time_scale
	
	await transition.transition_in(time_scale)
	
	callback.call()
	
	if out_transition != &"":
		transition = _get_transition_by_name(out_transition)
		transition.set_in()
	if out_time_scale >= 0.0:
		time_scale = out_time_scale
	
	await transition.transition_out(time_scale)

func register_transition(transition: SceneTransition) -> void:
	_transitions.set(transition.name, transition)

func unregister_transition(transition: SceneTransition) -> void:
	_transitions.erase(transition.name)

#region private_functions
func _create_scene_parent() -> void:
	_scene_parent = Node.new()
	_scene_parent.name = &"SceneParent"
	add_child(_scene_parent)

func _get_transition_by_name(transition_name: StringName) -> SceneTransition:
	return _transitions.get(transition_name)
