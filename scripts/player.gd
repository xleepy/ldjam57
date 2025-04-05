extends CharacterBody2D


@export var speed: int = Global.tile_size * 2

var directionsMap: Dictionary = {
	'move_up': Vector2.UP,
	'move_down': Vector2.DOWN,
	'move_right': Vector2.RIGHT,
	'move_left': Vector2.LEFT
}


var move_actions = []

func _ready() -> void:
	var floor: TileMapLayer = $"../Floor"
	var used_cells = floor.get_used_cells()
	
	print(used_cells)
	var all_actions: Array = InputMap.get_actions()
	for action in all_actions:
		if action.begins_with("move_"):
			move_actions.append(action)

func move(direction: Vector2) -> void:
	if direction.length() > 0:
		direction = direction.normalized()
	
	# Set target velocity based on input direction
	var target_velocity = direction * speed
	var space_rid = get_world_2d().space
	var space_state = PhysicsServer2D.space_get_direct_state(space_rid)
	var raycast_distance = target_velocity.length() * get_physics_process_delta_time() 
	# Create raycast query from current position in the direction of movement
	var query = PhysicsRayQueryParameters2D.create(
		global_position,
		global_position + direction * raycast_distance
	)
	var result = space_state.intersect_ray(query)
	if result and result.collider.is_in_group("Wall"):
		print('here', result)
		# Calculate the normal of the wall
		var wall_normal = result.normal
		# Project the velocity onto the wall's surface to allow sliding
		if wall_normal.dot(direction) < 0:
			target_velocity = target_velocity.slide(wall_normal)
	
	# Apply acceleration for smooth movement
	velocity = velocity.lerp(target_velocity, speed * get_physics_process_delta_time())
	
	move_and_slide()

	

func _physics_process(delta: float) -> void:
	for action in move_actions:
		if Input.is_action_pressed(action):
			var move_vector = directionsMap[action]
			move(move_vector)


func _on_body_area_body_entered(body: Node2D) -> void:
	print('entered node: ', body)
