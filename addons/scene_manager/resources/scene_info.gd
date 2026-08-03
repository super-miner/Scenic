class_name SceneInfo extends Resource

#region constants
const LOAD_INFO: String = 							"[Scenes] %s loaded"
const UNLOAD_INFO: String = 						"[Scenes] %s unloaded"
const RELOAD_WARNING: String = 						"[Scenes] Attempting to load \"%s\" after it has already been loaded"
const UNLOAD_NOTHING_WARNING: String = 				"[Scenes] Attempting to unload \"%s\" when it is already unloaded"
const LOAD_START_FAILED_ERROR: String = 			"[Scenes] Failed to start loading the scene from path \"%s\""
const LOAD_FAILED_ERROR: String = 					"[Scenes] Failed to load the scene from path \"%s\""
const LOAD_FAILED_INVALID_RESOURCE_ERROR: String = 	"[Scenes] Failed to load the scene from path \"%s\" (Invalid resource)"

#region enums
enum SceneLoadingState {
	NOT_LOADED,
	LOADING,
	LOADED
}

#region signals
signal loaded_scene

#region exports
@export var name: StringName = &""
@export_file("*.tscn") var path: String = ""
@export var initial: bool = false
@export var load_on_start: bool = false

#region references
var owner: Scene = null
var _scene: PackedScene = null
var _instance: Scene = null

#region state
var _state: SceneLoadingState = SceneLoadingState.NOT_LOADED
var _loading_progress: float = 0.0

#region public_functions
func load_scene() -> void:
	if _scene != null:
		push_warning(RELOAD_WARNING % path)
		return
	
	var result = ResourceLoader.load_threaded_request(path, "PackedScene")
	if result != OK:
		push_error(LOAD_START_FAILED_ERROR % path)
		return
	
	_loading_progress = 0.0
	_state = SceneLoadingState.LOADING

func unload_scene() -> void:
	if _scene == null:
		push_warning(UNLOAD_NOTHING_WARNING % path)
		return
	
	_scene = null
	_state = SceneLoadingState.NOT_LOADED
	
	print_verbose(UNLOAD_INFO % name)

func poll_loading_progress() -> void:
	if _state != SceneLoadingState.LOADING:
		return
	
	var progress = []
	var status = ResourceLoader.load_threaded_get_status(path, progress)
	
	match status:
		ResourceLoader.ThreadLoadStatus.THREAD_LOAD_FAILED:
			push_error(LOAD_FAILED_ERROR % path)
			_state = SceneLoadingState.NOT_LOADED
		
		ResourceLoader.ThreadLoadStatus.THREAD_LOAD_INVALID_RESOURCE:
			push_error(LOAD_FAILED_INVALID_RESOURCE_ERROR % path)
			_state = SceneLoadingState.NOT_LOADED
		
		ResourceLoader.ThreadLoadStatus.THREAD_LOAD_IN_PROGRESS:
			_loading_progress = progress[0]
		
		ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
			_loading_progress = 1.0
			_scene = ResourceLoader.load_threaded_get(path)
			_state = SceneLoadingState.LOADED
			
			loaded_scene.emit()
			
			print_verbose(LOAD_INFO % name)

func instantiate() -> Scene:
	_instance = _scene.instantiate()
	_instance.name = name
	return _instance

func queue_free() -> void:
	_instance.queue_free()
	_instance = null

func get_state() -> SceneLoadingState:
	return _state

func get_instance() -> Scene:
	return _instance
