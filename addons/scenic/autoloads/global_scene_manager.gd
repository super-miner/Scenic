extends Node

#region constants
const NO_GLOBAL_MANAGER_ERROR: String = "[Scenic] Attempting to perform a global scene operation with no global scene manager"
const RE_REGISTER_SCENE_ERROR: String = "[Scenic] Multiple global scene managers defined. Undefined behaviour."

#region references
var _target_scene_manager: SceneManager = null

#region node_events
func _enter_tree() -> void:
	Performance.add_custom_monitor("global_scene_manager/scenes_loaded", _get_loaded_scenes_count)
	Performance.add_custom_monitor("global_scene_manager/scenes_active", _get_active_scenes_count)

func _exit_tree() -> void:
	Performance.remove_custom_monitor("global_scene_manager/scenes_loaded")
	Performance.remove_custom_monitor("global_scene_manager/scenes_active")

#region public_functions
func register_scene_manager(scene_manager: SceneManager) -> void:
	if _target_scene_manager != null:
		push_warning(RE_REGISTER_SCENE_ERROR)
		return
	
	_target_scene_manager = scene_manager

func unregister_scene_manager(scene_manager: SceneManager) -> void:
	if _target_scene_manager != scene_manager:
		return
	
	_target_scene_manager = null

func force_load(scene_name: StringName, scene_owner: StringName = &"Global") -> void:
	if _target_scene_manager == null:
		push_error(NO_GLOBAL_MANAGER_ERROR)
		return
	
	_target_scene_manager.force_load(scene_name, scene_owner)

func force_unload(scene_name: StringName) -> void:
	if _target_scene_manager == null:
		push_error(NO_GLOBAL_MANAGER_ERROR)
		return
	
	_target_scene_manager.force_unload(scene_name)

func queue_add_scene(scene_name: StringName, data: Variant = null) -> void:
	if _target_scene_manager == null:
		push_error(NO_GLOBAL_MANAGER_ERROR)
		return
	
	_target_scene_manager.queue_add_scene(scene_name, data)

func queue_add_scenes(scene_names: Array[StringName], datas: Array[Variant] = []) -> void:
	if _target_scene_manager == null:
		push_error(NO_GLOBAL_MANAGER_ERROR)
		return
	
	_target_scene_manager.queue_add_scenes(scene_names, datas)

func queue_reload_scene(scene_name: StringName, data: Variant = null) -> void:
	if _target_scene_manager == null:
		push_error(NO_GLOBAL_MANAGER_ERROR)
		return
	
	_target_scene_manager.queue_reload_scene(scene_name, data)

func queue_reload_scenes(scene_names: Array[StringName], datas: Array[Variant] = []) -> void:
	if _target_scene_manager == null:
		push_error(NO_GLOBAL_MANAGER_ERROR)
		return
	
	_target_scene_manager.queue_reload_scenes(scene_names, datas)

func queue_remove_scene(scene_name: StringName) -> void:
	if _target_scene_manager == null:
		push_error(NO_GLOBAL_MANAGER_ERROR)
		return
	
	_target_scene_manager.queue_remove_scene(scene_name)

func queue_remove_scenes(exclude_tags: Array[String] = []) -> void:
	if _target_scene_manager == null:
		push_error(NO_GLOBAL_MANAGER_ERROR)
		return
	
	_target_scene_manager.queue_remove_scenes(exclude_tags)

func queue_set_scene(scene_name: StringName, data: Variant = null, exclude_tags: Array[String] = []) -> void:
	if _target_scene_manager == null:
		push_error(NO_GLOBAL_MANAGER_ERROR)
		return
	
	_target_scene_manager.queue_set_scene(scene_name, data, exclude_tags)

func apply() -> void:
	if _target_scene_manager == null:
		push_error(NO_GLOBAL_MANAGER_ERROR)
		return
	
	_target_scene_manager.apply()

func with_transition(in_transition: StringName, in_time_scale: float = 1.0, out_transition: StringName = &"", out_time_scale: float = -1.0) -> void:
	if _target_scene_manager == null:
		push_error(NO_GLOBAL_MANAGER_ERROR)
		return
	
	_target_scene_manager.with_transition(in_transition, in_time_scale, out_transition, out_time_scale)

func with_transition_callback(callback: Callable, in_transition: StringName, in_time_scale: float = 1.0, out_transition: StringName = &"", out_time_scale: float = -1.0) -> void:
	if _target_scene_manager == null:
		push_error(NO_GLOBAL_MANAGER_ERROR)
		return
	
	_target_scene_manager.with_transition_callback(callback, in_transition, in_time_scale, out_transition, out_time_scale)

#region private_functions
func _get_loaded_scenes_count() -> int:
	return 0 if _target_scene_manager == null else _target_scene_manager.get_loaded_scenes_count()

func _get_active_scenes_count() -> int:
	return 0 if _target_scene_manager == null else _target_scene_manager.get_active_scenes_count()
