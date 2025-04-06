extends StaticBody2D

@onready var player: Player = $"../Player"

func interact() -> void:
	player.hide_player()
	player.get_node("Label").text = "Hidden!"
