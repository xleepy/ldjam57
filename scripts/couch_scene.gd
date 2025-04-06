extends InteractableObject

@onready var animation: AnimatedSprite2D = $Green
@export_enum("red", "green", "purple") var chosen_animation: String = "green"

func _ready() -> void:
	if animation and chosen_animation:
		animation.play(chosen_animation)


func interact() -> void:
	player.sit(global_position.y + 0.5)
