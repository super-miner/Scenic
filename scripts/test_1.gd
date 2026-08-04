class_name Test1 extends Scene

func _start(data: Variant) -> void:
	print("Data: %s" % data)

func _ready() -> void:
	GlobalSceneManager.force_load(&"Test 3", &"Test 1")

func test_1() -> void:
	GlobalSceneManager.queue_reload_scene(&"Test 1", %HSlider.value)
	GlobalSceneManager.apply()

func test_2() -> void:
	GlobalSceneManager.queue_set_scene(&"Test 2", %HSlider.value, [&"Overlay"])
	GlobalSceneManager.with_transition_callback(func ():
		print("Transition callback")
	, &"Fade")

func test_3() -> void:
	GlobalSceneManager.queue_add_scene(&"Test 3")
	GlobalSceneManager.with_transition(&"Fade", 2.0)
	
