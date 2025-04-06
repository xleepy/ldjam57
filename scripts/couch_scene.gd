extends StaticBody2D

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D
@export_enum("red", "green", "purple") var chosen_animation: String = "green"

func _ready() -> void:
	if animation and chosen_animation:
		animation.play(chosen_animation)
