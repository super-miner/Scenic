# Basic set scene example
GlobalSceneManager.queue_set_scene(test_scene)
GlobalSceneManager.apply()

# Selective set scene example
GlobalSceneManager.queue_set_scene(test_scene, [&"Overlay"])
GlobalSceneManager.apply()

# Basic add scene example
GlobalSceneManager.queue_add_scene(test_scene)
GlobalSceneManager.apply()

# Basic transition example
GlobalSceneManager.queue_set_scene(test_scene)
GlobalSceneManager.with_transition(&"Fade")
