if ...: # Suppresses errors on the rest of this script
	pass



## Basic set scene example
GlobalSceneManager.queue_set_scene(test_scene)
GlobalSceneManager.apply()



## Selective set scene example
GlobalSceneManager.queue_set_scene(test_scene, [&"Overlay"])
GlobalSceneManager.apply()



## Basic add scene example
GlobalSceneManager.queue_add_scene(test_scene)
GlobalSceneManager.apply()



## Basic transition example
GlobalSceneManager.queue_set_scene(test_scene)
GlobalSceneManager.with_transition(&"Fade")



## Throws an error and only does first scene operations and transition
GlobalSceneManager.queue_set_scene(test_scene)
GlobalSceneManager.with_transition(&"Fade")

GlobalSceneManager.queue_set_scene(test_scene_2)
GlobalSceneManager.with_transition(&"Fade")



## Runs sequentially
GlobalSceneManager.queue_set_scene(test_scene)
await GlobalSceneManager.with_transition(&"Fade")

GlobalSceneManager.queue_set_scene(test_scene_2)
GlobalSceneManager.with_transition(&"Fade")



## Load scene far in advance
GlobalSceneManager.queue_set_scene(test_scene)

# ... (some code)

GlobalSceneManager.with_transition(&"Fade")



## Load scene far in advance without blocking other scenes from loading
GlobalSceneManager.preload(test_scene)

# ... (some code)

GlobalSceneManager.queue_set_scene(test_scene)
GlobalSceneManager.with_transition(&"Fade")



## Preload with manual freeing
GlobalSceneManager.preload(test_scene)

# ... (some code)

if ...:
	GlobalSceneManager.queue_set_scene(test_scene)
	GlobalSceneManager.with_transition(&"Fade")
else:
	GlobalSceneManager.free(test_scene)
	GlobalSceneManager.queue_set_scene(test_scene_2)
	GlobalSceneManager.with_transition(&"Fade")



## Preload with automatic freeing
GlobalSceneManager.preload(test_scene, current_scene) # Setting the owner to current_scene so that it gets freed current_scene goes away

# ... (some code)

if ...:
	GlobalSceneManager.queue_set_scene(test_scene)
	GlobalSceneManager.with_transition(&"Fade")
else:
	GlobalSceneManager.queue_set_scene(test_scene_2)
	GlobalSceneManager.with_transition(&"Fade")



## Does nothing, does not block scene loading, and throws a warning
GlobalSceneManager.queue_set_scene(test_scene)
GlobalSceneManager.queue_remove_scene(test_scene) # Note we are removing by PackedScene reference here
GlobalSceneManager.with_transition(&"Fade")
