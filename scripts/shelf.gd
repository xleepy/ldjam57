extends InteractableObject

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D
@export_enum("empty", "with_dishes", "with_books_1", "with_books_2", "with_books_3") var variant = "empty"

func _ready() -> void:
	animation.play(variant)
	
