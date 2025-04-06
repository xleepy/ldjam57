extends Node2D

@export_enum("left_wall", "right_wall", "hallway") var room_variant = "hallway"

var room_visibility_by_variant: Dictionary = {
	'left_wall': {"wall": "LeftWall", "door": "RightWall"},
	"right_wall": {"wall": "RightWall", "door": "LeftWall"}
}

func _ready() -> void:
	if room_variant == "hallway":
		get_node("RightWall").queue_free()
		get_node("LeftWall").queue_free()
		return
	
	var visibility = room_visibility_by_variant[room_variant]
	if visibility:
		get_node(visibility['wall']).visible = true	
		get_node(visibility['door']).queue_free()
		
