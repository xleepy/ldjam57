extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var speed: int = Global.tile_size * 2

var directionsMap: Dictionary = {
	'move_up': Vector2.UP,
	'move_down': Vector2.DOWN,
	'move_right': Vector2.RIGHT,
	'move_left': Vector2.LEFT
}


var current_interactable_item: Node2D

var move_actions = []

func _ready() -> void:
	var floor: TileMapLayer = $"../Floor"
	var used_cells = floor.get_used_cells()
	
	print(used_cells)
	var all_actions: Array = InputMap.get_actions()
	for action in all_actions:
		if action.begins_with("move_"):
			move_actions.append(action)

func intersect_ray(direction: Vector2, distance: float) -> Dictionary:
	var space_rid = get_world_2d().space
	var space_state = PhysicsServer2D.space_get_direct_state(space_rid)
	# Create raycast query from current position in the direction of movement
	var query = PhysicsRayQueryParameters2D.create(
		global_position,
		global_position + direction * distance
	)
	return space_state.intersect_ray(query)

func move(direction: Vector2) -> void:
	if direction.length() > 0:
		direction = direction.normalized()
	
	# Set target velocity based on input direction
	var target_velocity = direction * speed
	var raycast_distance = target_velocity.length() * get_physics_process_delta_time() 
	var result = intersect_ray(direction, raycast_distance)
	if result and result.collider.is_in_group("Wall"):
		# Calculate the normal of the wall
		var wall_normal = result.normal
		# Project the velocity onto the wall's surface to allow sliding
		if wall_normal.dot(direction) < 0:
			target_velocity = target_velocity.slide(wall_normal)
	
	# Apply acceleration for smooth movement
	velocity = velocity.lerp(target_velocity, speed * get_physics_process_delta_time())
	
	move_and_slide()


func check_object_by_move_direction(direction: Vector2):
	var next_result = intersect_ray(direction, Global.tile_size)
	if next_result and next_result.collider.is_in_group("Interactable"):
		current_interactable_item = next_result.collider
		z_index = 1 if direction == Vector2.UP else 0
		$Label.visible = true
	else:
		current_interactable_item = null
		$Label.visible = false
		$Label.text = "[E] to interact"

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and current_interactable_item:
		$Label.text = "Interacted!"
		current_interactable_item.interact()

func _physics_process(delta: float) -> void:
	for action in move_actions:
		if Input.is_action_pressed(action):
			var move_vector = directionsMap[action]
			move(move_vector)
			check_object_by_move_direction(move_vector)
	# flip player
	if Input.is_action_pressed("move_right"):
		animated_sprite.scale.x = 1.0
	elif Input.is_action_pressed("move_left"):
		animated_sprite.scale.x = -1.0
	
	# set animation
	if velocity.length() > 0:
		animated_sprite.play("walk")
	else:
		animated_sprite.stop()
		animated_sprite.play("idle")
			


func _on_body_area_body_entered(body: Node2D) -> void:
	print('entered node: ', body)


func _on_body_area_body_exited(body: Node2D) -> void:
	pass
