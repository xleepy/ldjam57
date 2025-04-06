extends StaticBody2D

class_name InteractableObject

@onready var player: Player = $"../Player"

func interact() -> void:
	player.get_node("Label").text = "Interacted"	
