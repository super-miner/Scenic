class_name Test1 extends Scene

@export var test_2_scene: PackedScene = null
@export var test_3_scene: PackedScene = null

func _ready() -> void:
	GlobalSceneManager.force_load(&"Test 3", &"Test 1")

func test_2() -> void:
	GlobalSceneManager.queue_set_scene(&"Test 2", [&"Overlay"])
	GlobalSceneManager.with_transition_callback(func ():
		print("Transition callback")
	, &"Fade")

func test_3() -> void:
	GlobalSceneManager.queue_add_scene(&"Test 3")
	GlobalSceneManager.with_transition(&"Fade", 2.0)
	
