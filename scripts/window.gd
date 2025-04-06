extends Area2D

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D
@export_enum("animated_tree", "tree_variant1", "tree_variant2", "tree_variant3") var chosen_animation: String = "animated_tree"

func _ready():
	if animation and chosen_animation:
		animation.play(chosen_animation)
