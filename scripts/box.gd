extends InteractableObject

func interact() -> void:
	player.hide_player()
	player.get_node("Label").text = "Hidden!"
