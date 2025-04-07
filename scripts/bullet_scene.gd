extends CharacterBody2D

var speed: int = 300
var direction: Vector2 = Vector2(0,0)

func _physics_process(delta):
	self.velocity = direction * speed
	move_and_slide()

func _on_area_2d_body_entered(body: Node2D) -> void:
	
	if body.is_in_group("Wall"):
		queue_free()
		


func _on_area_2d_area_entered(area: Area2D) -> void:
	var parent = area.get_parent()
	if parent.is_in_group("Enemy"):
		parent.take_damage()
		queue_free()
