extends Panel

@onready var field: PackedScene = load("res://scenes/ui/key_mapping.tscn")


func _on_button_pressed() -> void:
	$"../Menu".visible = true
	$".".visible = false

var current_mapping: Dictionary = {}

# TODO: finalise remapping
func get_project_actions():
	var actions = []
	for prop in ProjectSettings.get_property_list():
		var prop_name = prop.get("name", "")
		if prop_name.begins_with('input/'):
			prop_name = prop_name.replace('input/', '')
			prop_name = prop_name.substr(0, prop_name.find("."))
			if not actions.has(prop_name):
				actions.append(prop_name)
	return actions


func get_keys_for_action(action: String) -> Array:
	var events = InputMap.action_get_events(action)
	var keys: Array = []
	for event in events:
		if event is InputEventKey or event is InputEventMouse:
			keys.append(event.as_text().replace("(Physical)", ""	))
	return keys

func create_field(action: String) -> void:
	var new_field = field.instantiate()
	var label: Label = new_field.get_node("Label")
	label.text = action
	var keys = get_keys_for_action(action)
	var input: TextEdit = new_field.get_node("Input")
	input.text = ", ".join(keys)
	var change = func():
		var current_text = input.text
		current_mapping[action] = current_text
		print(action, current_text)
		
	input.text_changed.connect(change)
	$Container/InputsContainer.add_child(new_field)

func render_fields():
	var all_actions = InputMap.get_actions()
	for action in all_actions:
		if not action.begins_with("ui_"):
			create_field(action)

func _ready():
	render_fields()


func _on_save_pressed() -> void:
	var config = ConfigFile.new()
	
	pass # Replace with function body.
