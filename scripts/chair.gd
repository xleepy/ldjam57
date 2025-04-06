extends InteractableObject

@export_enum("purple_chair", "green_chair") var variant = "green_chair"
@onready var animation: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	animation.play(variant)


func interact():
	player.sit(global_position.y + 25)
