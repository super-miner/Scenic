if ...: # Suppresses errors on the rest of this script
	pass



## Basic set scene example
GlobalSceneManager.queue_set_scene(&"Test")
GlobalSceneManager.apply()



## Selective set scene example
GlobalSceneManager.queue_set_scene(&"Test", [&"Overlay"])
GlobalSceneManager.apply()



## Basic add scene example
GlobalSceneManager.queue_add_scene(&"Test")
GlobalSceneManager.apply()



## Basic transition example
GlobalSceneManager.queue_set_scene(&"Test")
GlobalSceneManager.with_transition(&"Fade")



## Throws an error and only does first scene operations and transition
GlobalSceneManager.queue_set_scene(&"Test")
GlobalSceneManager.with_transition(&"Fade")

GlobalSceneManager.queue_set_scene(&"Test 2")
GlobalSceneManager.with_transition(&"Fade")



## Runs sequentially
GlobalSceneManager.queue_set_scene(&"Test")
await GlobalSceneManager.with_transition(&"Fade")

GlobalSceneManager.queue_set_scene(&"Test 2")
GlobalSceneManager.with_transition(&"Fade")



## Load scene far in advance
GlobalSceneManager.queue_set_scene(&"Test")

# ... (some code)

GlobalSceneManager.with_transition(&"Fade")



## Load scene far in advance without blocking other scenes from loading
GlobalSceneManager.force_load(&"Test")

# ... (some code)

GlobalSceneManager.queue_set_scene(&"Test")
GlobalSceneManager.with_transition(&"Fade")



## Preload with manual freeing
GlobalSceneManager.force_load(&"Test")

# ... (some code)

if ...:
	GlobalSceneManager.queue_set_scene(&"Test")
	GlobalSceneManager.with_transition(&"Fade")
else:
	GlobalSceneManager.force_unload(&"Test")
	GlobalSceneManager.queue_set_scene(&"Test 2")
	GlobalSceneManager.with_transition(&"Fade")



## Preload with automatic freeing
GlobalSceneManager.force_load(&"Test", &"Current") # Setting the owner to current_scene so that it gets freed Current unloads

# ... (some code)

if ...:
	GlobalSceneManager.queue_set_scene(&"Test")
	GlobalSceneManager.with_transition(&"Fade")
else:
	GlobalSceneManager.queue_set_scene(&"Test 2")
	GlobalSceneManager.with_transition(&"Fade")



## Does nothing, does not block scene loading, and throws a warning
GlobalSceneManager.queue_set_scene(&"Test")
GlobalSceneManager.queue_remove_scene(&"Test")
GlobalSceneManager.with_transition(&"Fade")
