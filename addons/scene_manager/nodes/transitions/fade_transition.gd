@icon("res://addons/scene_manager/icons/fast_forward.svg")
class_name FadeTransition extends SceneTransition

#region exports
@export var _curtain: Control = null
@export var _opaque_color: Color = Color.BLACK:
	set(value):
		_opaque_color = value
		_update_transparent_color()
@export var _duration: float = 0.5
@export var _ease: Tween.EaseType = Tween.EaseType.EASE_IN_OUT
@export var _transition: Tween.TransitionType = Tween.TransitionType.TRANS_CUBIC

#region identity
var _transparent_color: Color

#region node_events
func _enter_tree() -> void:
	_update_transparent_color()

#region public_functions
func transition_in(time_scale: float = 1.0) -> void:
	_curtain.mouse_filter = Control.MOUSE_FILTER_STOP
	
	var tween = create_tween()
	tween.tween_property(_curtain, "modulate", _opaque_color, _duration * time_scale).set_ease(_ease).set_trans(_transition)
	
	await tween.finished

func set_in() -> void:
	_curtain.mouse_filter = Control.MOUSE_FILTER_STOP
	_curtain.modulate = _opaque_color

func transition_out(time_scale: float = 1.0) -> void:
	_curtain.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var tween = create_tween()
	tween.tween_property(_curtain, "modulate", _transparent_color, _duration * time_scale).set_ease(_ease).set_trans(_transition)
	
	await tween.finished

func set_out() -> void:
	_curtain.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_curtain.modulate = _transparent_color

#region private_functions
func _update_transparent_color() -> void:
	_transparent_color = Color(_opaque_color.r, _opaque_color.g, _opaque_color.b, 0.0)
