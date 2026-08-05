@icon("res://addons/scene_manager/icons/fast_forward.svg")
@abstract class_name SceneTransition extends CanvasLayer

#region node_events
func _ready() -> void:
	set_out()
	
	if get_parent() is SceneManager:
		get_parent().register_transition(self)

func _exit_tree() -> void:
	if get_parent() is SceneManager:
		get_parent().unregister_transition(self)

#region public_functions
@abstract func transition_in(time_scale: float = 1.0) -> void
@abstract func set_in() -> void
@abstract func transition_out(time_scale: float = 1.0) -> void
@abstract func set_out() -> void
