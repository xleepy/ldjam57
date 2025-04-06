extends CharacterBody2D

class_name Player

@export var speed: int = Global.tile_size * 2
@onready var animation: AnimatedSprite2D = $AnimatedSprite2D

var directionsMap: Dictionary = {
	'move_up': Vector2.UP,
	'move_down': Vector2.DOWN,
	'move_right': Vector2.RIGHT,
	'move_left': Vector2.LEFT
}

# check directions also if user moves forward 
# kind of field of view
var interactable_areas_to_check: Dictionary = {
	'move_up': [Vector2.LEFT, Vector2.RIGHT],
	'move_down': [Vector2.LEFT, Vector2.RIGHT],
	'move_right': [Vector2.UP, Vector2.DOWN],
	'move_left': [Vector2.UP, Vector2.DOWN]
}

var current_action: String

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
	animation.play("walk")
	if direction == Vector2.LEFT:
		animation.scale.x = -1.0
	elif direction == Vector2.RIGHT:
		animation.scale.x = 1
		
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

func reset_interactable() -> void:
	if current_interactable_item:
		current_interactable_item.z_index = 0
		current_interactable_item = null
		$Label.visible = false
		$Label.text = "[E] to interact"

func set_interactable(node: Node2D, direction: Vector2) -> void:
		current_interactable_item = node
		z_index = 1 if direction == Vector2.UP else 0
		$Label.visible = true

# check if object in front of player movement
# check if object in visible area defined in interactable_areas_to_check
func check_object_by_move_direction(move_direction: String, direction: Vector2):
	var half_of_tile = Global.tile_size * 0.75
	var possible_distance = 0
	if current_interactable_item:
		possible_distance = direction.distance_to(current_interactable_item.global_position)
	var distance_to_object = max(half_of_tile, possible_distance)
	print('possible distance', possible_distance)
	
	var next_result = intersect_ray(direction, distance_to_object)
	if next_result and next_result.collider.is_in_group("Interactable"):
		set_interactable(next_result.collider, direction)
	else:
		var other_possible_interactable = interactable_areas_to_check[move_direction]
		var possible_result: Dictionary
		var found_direction: Vector2
		for other_direction in other_possible_interactable:
			possible_result = intersect_ray(other_direction, distance_to_object)
			found_direction = other_direction
			if possible_result:
				break
		if possible_result and possible_result.collider.is_in_group("Interactable"):
			set_interactable(possible_result.collider, found_direction)
		else:
			reset_interactable()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and current_interactable_item:
		current_interactable_item.interact()

func _physics_process(delta: float) -> void:
	for action in move_actions:
		if Input.is_action_pressed(action):
			current_action = action
			var move_vector = directionsMap[action]
			move(move_vector)
			check_object_by_move_direction(action, move_vector)
			
	if current_action and Input.is_action_just_released(current_action):
		animation.play("idle")
			


func hide_player() -> void:
	if current_interactable_item:
		z_index = 0
		current_interactable_item.z_index = 1
		animation.play("hide_behind")
		#Dialogic.start("Prolog")

		
