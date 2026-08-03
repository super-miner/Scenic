@tool
extends EditorProperty

#region references
var _droppable_tree = preload("res://addons/scene_manager/inspectors/droppable_tree.gd")
var _editor_theme: Theme = null
var _tree: Tree = null

#region state
var _scenes: Dictionary
var _updating: bool = false
var _item_just_added: StringName = &""

#region node_events
func _init(scenes: Dictionary) -> void:
	if _editor_theme == null:
		_editor_theme = EditorInterface.get_editor_theme()
	
	_tree = _droppable_tree.new()
	_tree.columns = 2
	_tree.custom_minimum_size = Vector2(0.0, 300.0)
	_tree.hide_root = true
	_tree.hide_folding = true
	_tree.scroll_horizontal_enabled = false
	_tree.scroll_vertical_enabled = false
	_tree.button_clicked.connect(_on_button_clicked)
	_tree.item_edited.connect(_on_item_edited)
	_tree.dropped_file.connect(_on_dropped_file)
	add_child(_tree)
	set_bottom_editor(_tree)
	
	_scenes = scenes
	_update_list()

func _update_property() -> void:
	var new_scenes = get_edited_object()[get_edited_property()]
	
	_updating = true
	_scenes = new_scenes
	_update_list()
	_updating = false

#region callbacks
func _on_button_clicked(item: TreeItem, column: int, id: int, mouse_button: int) -> void:
	if _updating:
		return
	
	var new_scenes = _scenes.duplicate(true)
	var clicked_scene_name = item.get_text(0)
	
	for scene_info in new_scenes.values():
		if scene_info.name != clicked_scene_name:
			continue
		
		match id:
			0:
				scene_info.initial = !scene_info.initial
			1:
				scene_info.load_on_start = !scene_info.load_on_start
			2:
				new_scenes.erase(scene_info.name)
		
		break
	
	emit_changed(get_edited_property(), new_scenes)

func _on_item_edited() -> void:
	var item = _tree.get_edited()
	var column = _tree.get_edited_column()
	
	var new_scenes = _scenes.duplicate(true)
	var scene_info = new_scenes.get(item.get_metadata(0))
	
	match column:
		0:
			new_scenes.erase(scene_info.name)
			scene_info.name = item.get_text(0)
			new_scenes.set(scene_info.name, scene_info)
		1:
			scene_info.path = item.get_text(1)
	
	emit_changed(get_edited_property(), new_scenes)

func _on_dropped_file(path: String) -> void:
	var new_scenes = _scenes.duplicate(true)
	var new_scene_info = SceneInfo.new()
	new_scene_info.name = find_valid_name(path.get_file().get_basename().capitalize())
	new_scene_info.uid = ResourceLoader.get_resource_uid(path)
	new_scenes.set(new_scene_info.name, new_scene_info)
	
	_item_just_added = new_scene_info.name
	emit_changed(get_edited_property(), new_scenes)

#region private_functions
func _update_list() -> void:
	_tree.clear()
	
	var new_item = null
	var root = _tree.create_item()
	for scene_info in _scenes.values():
		var item = _tree.create_item(root)
		item.set_metadata(0, scene_info.name)
		item.set_text(0, scene_info.name)
		item.set_editable(0, true)
		item.set_text(1, scene_info.get_path())
		item.add_button(1, _editor_theme.get_icon("AutoPlay", "EditorIcons"), 0, false, "Initial")
		item.set_button_color(1, 0, Color(1.0, 1.0, 1.0, 1.0 if scene_info.initial else 0.5))
		item.add_button(1, _editor_theme.get_icon("ResourcePreloader", "EditorIcons"), 1, false, "Load on Start")
		item.set_button_color(1, 1, Color(1.0, 1.0, 1.0, 1.0 if scene_info.load_on_start else 0.5))
		item.add_button(1, _editor_theme.get_icon("Remove", "EditorIcons"), 2, false, "Remove")
		
		if _item_just_added == scene_info.name:
			new_item = item
	
	if _item_just_added != &"" && new_item != null:
		_tree.set_selected(new_item, 0)
		await get_tree().process_frame
		_tree.edit_selected(true)
		
		_item_just_added = &""

func find_valid_name(name: StringName) -> StringName:
	var current_name = name
	var index = 1
	while _scenes.has(current_name):
		current_name = "%s_%d" % [name, index]
		index += 1
	
	return current_name
