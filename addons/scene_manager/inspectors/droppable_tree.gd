@tool
extends Tree

#region signals
signal dropped_file

#region exports
@export var required_ext: String = "tscn"

#region node_events
func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	if data["type"] != "files" || data["files"].size() == 0:
		return false
	
	var ext = data["files"][0].get_extension().to_lower()
	return ext == required_ext

func _drop_data(at_position: Vector2, data: Variant) -> void:
	dropped_file.emit(data["files"][0])
