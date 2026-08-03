@icon("res://addons/scene_manager/icons/layers.svg")
class_name SceneManager extends Node

#region constants
const SCENE_ADD_QUEUED_INFO: String = 			"[Scenes] %s queued for creation"
const SCENE_REMOVE_QUEUED_INFO: String = 		"[Scenes] %s queued for deletion"
const SCENE_INSTANTIATED_INFO: String = 		"[Scenes] %s instantiated"
const SCENE_FREED_INFO: String = 				"[Scenes] %s freed"
const SCENE_NOT_PRELOADED_WARNING: String = 	"[Scenes] %s had not started loading before _apply_scene_deltas was called"
const INVALID_OWNER_ERROR: String = 			"[Scenes] Invalid scene owner %s. Must be \"Global\" or the name of a currently loaded scene (%d scenes currently loaded)"
const INVALID_TIME_SCALE_ERROR: String = 		"[Scenes] Invalid time scale %s. Setting time scale to 1.0"
const SCENE_ADD_IN_PROGRESS_ERROR: String = 	"[Scenes] Attempted to queue a scene add operation while a scene change was in progress"
const SCENE_REMOVE_IN_PROGRESS_ERROR: String = 	"[Scenes] Attempted to queue a scene remove operation while a scene change was in progress"
const SCENE_SET_IN_PROGRESS_ERROR: String = 	"[Scenes] Attempted to queue a scene set operation while a scene change was in progress"

#region enums
enum SceneChangeState {
	NONE,
	IN_PROGRESS
}

#region exports
@export var global: bool = true
@export var _scenes: Array[SceneInfo] = []

#region references
var _scene_parent: Node = null
var _internal_scenes: Dictionary = {} #{<scene_name>: <scene_info>}
var _active_scenes: Dictionary = {} #{<scene_name>: <scene_info>}
var _transitions: Dictionary = {}

#region state
var _state: SceneChangeState = SceneChangeState.NONE
var _queue_add: Dictionary = {} #{<scene_name>: <scene_info>}
var _queue_remove: Dictionary = {} #{<scene_name>: <scene_info>}
var _currently_loading: Dictionary = {} #{<scene_name>: <scene_info>}
var _force_loaded: Dictionary = {&"Global": {}} #{<owner_scene_name>: {<scene_name>: null}}

#region node_events
func _enter_tree() -> void:
	_create_internal_scenes()

func _ready() -> void:
	_create_scene_parent()
	
	if global:
		GlobalSceneManager.register_scene_manager(self)
	
	queue_remove_scenes()
	for scene_info in _internal_scenes.values():
		if scene_info.initial:
			queue_add_scene(scene_info.name)
	apply()

func _exit_tree() -> void:
	if global:
		GlobalSceneManager.unregister_scene_manager(self)

func _process(_delta: float) -> void:
	_poll_currently_loading()

#region public_functions
func force_load(scene_name: StringName, scene_owner: StringName = &"Global") -> void:
	if scene_owner != &"Global" && (scene_owner == null || !_active_scenes.has(scene_owner)):
		push_error(INVALID_OWNER_ERROR % [scene_owner, _active_scenes.size()])
		return
	
	var scene_info = _get_scene_info_by_name(scene_name)
	_force_loaded.get(scene_owner).set(scene_name, null)
	
	if scene_info.get_state() != SceneInfo.SceneLoadingState.LOADED:
		scene_info.load_scene()
		_currently_loading.set(scene_name, scene_info)

func force_unload(scene_name: StringName) -> void:
	var scene_info = _get_scene_info_by_name(scene_name)
	
	if scene_info.owner == null:
		return
	
	_force_loaded.get(scene_info.owner).erase(scene_name)
	scene_info.owner = null
	
	if !_active_scenes.has(scene_name):
		scene_info.unload_scene()
		_currently_loading.erase(scene_name)

func queue_add_scene(scene_name: StringName) -> void:
	if _state == SceneChangeState.IN_PROGRESS:
		push_error(SCENE_ADD_IN_PROGRESS_ERROR)
		return
	
	if _queue_remove.has(scene_name):
		_queue_remove.erase(scene_name)
	elif !_active_scenes.has(scene_name):
		var scene_info = _get_scene_info_by_name(scene_name)
		_queue_add.set(scene_name, scene_info)
		
		if scene_info.get_state() != SceneInfo.SceneLoadingState.LOADED:
			scene_info.load_scene()
			_currently_loading.set(scene_name, scene_info)
		
		print_verbose(SCENE_ADD_QUEUED_INFO % scene_name)

func queue_remove_scene(scene_name: StringName) -> void:
	if _state == SceneChangeState.IN_PROGRESS:
		push_error(SCENE_REMOVE_IN_PROGRESS_ERROR)
		return
	
	var scene_info = _get_scene_info_by_name(scene_name)
	if _queue_add.has(scene_name):
		_queue_add.erase(scene_name)
	elif _active_scenes.has(scene_name):
		_queue_remove.set(scene_name, scene_info)
		
		print_verbose(SCENE_REMOVE_QUEUED_INFO % scene_name)
	
	if scene_info.owner != &"Global" && !_active_scenes.has(scene_info.owner):
		scene_info.unload_scene() # Cancel scene loading
		_currently_loading.erase(scene_name)

func queue_remove_scenes(exclude_tags: Array[String] = []) -> void:
	if _state == SceneChangeState.IN_PROGRESS:
		push_error(SCENE_REMOVE_IN_PROGRESS_ERROR)
		return
	
	for scene_info in _active_scenes.values():
		var should_remove = true
		for tag in exclude_tags:
			if scene_info.get_instance().has_tag(tag):
				should_remove = false
				break
		
		if should_remove:
			queue_remove_scene(scene_info.name)

func queue_set_scene(scene_name: StringName, exclude_tags: Array[String] = []) -> void:
	if _state == SceneChangeState.IN_PROGRESS:
		push_error(SCENE_SET_IN_PROGRESS_ERROR)
		return
	
	queue_remove_scenes(exclude_tags)
	queue_add_scene(scene_name)

func apply() -> void:
	_state = SceneChangeState.IN_PROGRESS
	
	await _apply_scene_deltas()
	
	_state = SceneChangeState.NONE

func with_transition(in_transition: StringName, in_time_scale: float = 1.0, out_transition: StringName = &"", out_time_scale: float = -1.0) -> void:
	_state = SceneChangeState.IN_PROGRESS
	
	var transition = _get_transition_by_name(in_transition)
	var time_scale = in_time_scale
	if time_scale <= 0.0:
		push_error(INVALID_TIME_SCALE_ERROR % time_scale)
		time_scale = 1.0
	
	await transition.transition_in(time_scale)
	
	await _apply_scene_deltas()
	
	if out_transition != &"":
		transition = _get_transition_by_name(out_transition)
		transition.set_in()
	if out_time_scale > 0.0:
		time_scale = out_time_scale
	
	await transition.transition_out(time_scale)
	
	_state = SceneChangeState.NONE

func register_transition(transition: SceneTransition) -> void:
	_transitions.set(transition.name, transition)

func unregister_transition(transition: SceneTransition) -> void:
	_transitions.erase(transition.name)

#region private_functions
func _create_internal_scenes() -> void:
	for scene in _scenes:
		_internal_scenes.set(scene.name, scene)

func _create_scene_parent() -> void:
	_scene_parent = Node.new()
	_scene_parent.name = &"SceneParent"
	add_child(_scene_parent)

func _get_scene_info_by_name(scene_name: StringName) -> SceneInfo:
	return _internal_scenes.get(scene_name)

func _get_transition_by_name(transition_name: StringName) -> SceneTransition:
	return _transitions.get(transition_name)

func _poll_currently_loading() -> void:
	for scene_name in _currently_loading.keys():
		var scene_info = _get_scene_info_by_name(scene_name)
		
		scene_info.poll_loading_progress()
		if scene_info.get_state() != SceneInfo.SceneLoadingState.LOADING:
			_currently_loading.erase(scene_name)

func _wait_for_queued_scenes_to_load() -> void:
	for scene_info in _queue_add.values():
		if scene_info.get_state() == SceneInfo.SceneLoadingState.NOT_LOADED:
			push_warning(SCENE_NOT_PRELOADED_WARNING % scene_info.name)
			scene_info.load_scene() # This is just a fallback incase it didn't start loading when queued
		
		if scene_info.get_state() != SceneInfo.SceneLoadingState.LOADED:
			await scene_info.loaded_scene

func _apply_scene_deltas() -> void:
	await _wait_for_queued_scenes_to_load()
	
	for scene in _queue_add.values():
		_add_scene(scene)
	
	for scene in _queue_remove.values():
		_remove_scene(scene)
	
	_queue_add.clear()
	_queue_remove.clear()

func _add_scene(scene_info: SceneInfo) -> void:
	_active_scenes.set(scene_info.name, scene_info)
	_force_loaded.set(scene_info.name, {})
	
	var scene = scene_info.instantiate()

	scene.scene_manager = self
	
	_scene_parent.add_child(scene)
	
	print_verbose(SCENE_INSTANTIATED_INFO % scene_info.name)

func _remove_scene(scene_info: SceneInfo) -> void:
	_scene_parent.remove_child(scene_info.get_instance())
	scene_info.queue_free()
	
	for owned_name in _force_loaded.get(scene_info.name):
		if _active_scenes.has(owned_name):
			continue
		
		var owned_info = _get_scene_info_by_name(owned_name)
		owned_info.unload_scene() # Cancel scene loading
		_currently_loading.erase(owned_name)
	
	_active_scenes.erase(scene_info.name)
	_force_loaded.erase(scene_info.name)
	
	print_verbose(SCENE_FREED_INFO % scene_info.name)
