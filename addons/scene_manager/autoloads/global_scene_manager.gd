extends Node

#region constants
const NO_GLOBAL_MANAGER_ERROR: String = "[Scenes] Attempting to perform a global scene operation with no global scene manager"
const RE_REGISTER_SCENE_ERROR: String = "[Scenes] Multiple global scene managers defined. Undefined behaviour."

#region references
var _target_scene_manager: SceneManager = null

#region public_functions
func register_scene_manager(scene_manager: SceneManager) -> void:
	if _target_scene_manager != null:
		push_error(RE_REGISTER_SCENE_ERROR)
		return
	
	_target_scene_manager = scene_manager

func unregister_scene_manager(scene_manager: SceneManager) -> void:
	if _target_scene_manager != scene_manager:
		return
	
	_target_scene_manager = null

func add_scene(scene_scene: PackedScene) -> void:
	if _target_scene_manager == null:
		push_error(NO_GLOBAL_MANAGER_ERROR)
		return
	
	_target_scene_manager.add_scene(scene_scene)

func remove_scene(scene: Scene) -> void:
	if _target_scene_manager == null:
		push_error(NO_GLOBAL_MANAGER_ERROR)
		return
	
	_target_scene_manager.remove_scene(scene)

func remove_scenes(exclude_tags: Array[String] = []) -> void:
	if _target_scene_manager == null:
		push_error(NO_GLOBAL_MANAGER_ERROR)
		return
	
	_target_scene_manager.remove_scenes(exclude_tags)

func set_scene(scene_scene: PackedScene, exclude_tags: Array[String] = []) -> void:
	if _target_scene_manager == null:
		push_error(NO_GLOBAL_MANAGER_ERROR)
		return
	
	_target_scene_manager.set_scene(scene_scene, exclude_tags)

func with_transition(callback: Callable, in_transition: StringName, in_time_scale: float = 1.0, out_transition: StringName = &"", out_time_scale: float = -1.0) -> void:
	if _target_scene_manager == null:
		push_error(NO_GLOBAL_MANAGER_ERROR)
		return
	
	_target_scene_manager.with_transition(callback, in_transition, in_time_scale, out_transition, out_time_scale)
