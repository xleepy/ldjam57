extends CanvasLayer


func _on_settings_btn_pressed() -> void:
	$Menu.visible = false
	$Settings.visible = true


func _on_back_to_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn") 


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if $Settings.visible:
			$Settings.visible = false
			$Menu.visible = true
		else:
			$Menu.visible = !$Menu.visible
