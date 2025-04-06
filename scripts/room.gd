extends Node2D

@export_enum("left_wall", "right_wall", "hallway") var room_variant = "hallway"

var room_visibility_by_variant: Dictionary = {
	'left_wall': "LeftWall",
	"right_wall": "RightWall"
}

func _ready() -> void:
	var visibility = room_visibility_by_variant[room_variant]
	if visibility:
		get_node(visibility).visible = true	
		
