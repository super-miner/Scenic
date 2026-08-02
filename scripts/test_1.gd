class_name Test1 extends Scene

@export var test_2_scene: PackedScene = null
@export var test_3_scene: PackedScene = null

func test_2() -> void:
	GlobalSceneManager.with_transition(func ():
		GlobalSceneManager.set_scene(test_2_scene)
	, &"Fade")

func test_3() -> void:
	GlobalSceneManager.with_transition(func ():
		GlobalSceneManager.add_scene(test_3_scene)
	, &"Fade", 0.2)
