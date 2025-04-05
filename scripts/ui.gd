extends CanvasLayer

func _on_settings_btn_pressed() -> void:
	$Menu.visible = false
	$Settings.visible = true
	
func _on_new_game_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/level1.tscn")

func _on_quit_btn_pressed() -> void:
	get_tree().quit() # Replace with function body.
