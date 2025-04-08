extends CharacterBody2D

class_name Player

@export var speed: int = Global.tile_size * 2
@onready var animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var aimed_arm: Marker2D = $shoulder_pivot
@onready var bullet_spawn: Marker2D = $shoulder_pivot/aimed_arm/bullet_spawn
@onready var bullet_scene: PackedScene = preload("res://scenes/bullet_scene.tscn")

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
var is_hidden = false
var is_sitting = false

# idle, walk, aim, taking damage,
var state = 'idle'

var current_interactable_item: Node2D

var move_actions = []

var looking_direction: String = 'right'

func _ready() -> void:
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
	state = 'walk'
	if direction == Vector2.LEFT:
		looking_direction = 'left'
		animation.scale.x = -1.0
	elif direction == Vector2.RIGHT:
		animation.scale.x = 1
		looking_direction = 'right'
		
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
		z_index = 1
		current_interactable_item.z_index = 0
		$Label.visible = false
		$Label.text = "[E] to interact"
		is_sitting = false
		is_hidden = false
		current_interactable_item = null

func set_interactable(node: Node2D) -> void:
	if not node.is_in_group("Interactable"):
		return	
	current_interactable_item = node
	$Label.visible = true
	
func aim() -> void:
	state = 'aim'
	animation.play("aim")
	if looking_direction == 'left':
		aimed_arm.get_node("aimed_arm").scale.x = -1
	else: 
		aimed_arm.get_node("aimed_arm").scale.x = 1
		
	aimed_arm.visible = true

func reset_aim() -> void:
	state = 'idle'
	animation.play("idle")
	aimed_arm.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("aim"):
		aim()
	if event.is_action_pressed("interact") and current_interactable_item:
		current_interactable_item.interact()
	if event.is_action_released("aim"):
		reset_aim()
		
func handle_aim():
	var direction = (get_global_mouse_position() - global_position).normalized()
	var angle_to_mouse = direction.angle() + PI if looking_direction == 'left' else direction.angle()
	print('deg: ', rad_to_deg(angle_to_mouse))
	print('cos ', cos(angle_to_mouse))
	if abs(cos(angle_to_mouse)) >= 0.7:
		aimed_arm.rotation = angle_to_mouse


func shoot() -> void:
	print('shoot')
	var temp_bullet = bullet_scene.instantiate()
	temp_bullet.position = bullet_spawn.global_position
	temp_bullet.direction = (get_global_mouse_position() - bullet_spawn.global_position).normalized()
	get_node("bullets").add_child(temp_bullet)

func _physics_process(delta: float) -> void:
	if state == 'aim' and Input.is_action_just_pressed("attack"):
		shoot()
		return
	if state == 'aim':
		handle_aim()
		return
	for action in move_actions:
		if Input.is_action_pressed(action):
			current_action = action
			var move_vector = directionsMap[action]
			move(move_vector)
				
	if current_action and Input.is_action_just_released(current_action):
		animation.play("idle")
		state = 'idle'
	
	

func hide_player() -> void:
	if current_interactable_item:
		z_index = 0
		current_interactable_item.z_index = 1
		animation.play("hide_behind")
		is_hidden = true
		
func sit(y_position: float) -> void:
	animation.play('sit_front')
	global_position.y = y_position
	is_sitting = true

func _on_body_area_body_entered(body: Node2D) -> void:
	set_interactable(body)


func _on_interactable_area_body_exited(body: Node2D) -> void:
	reset_interactable()
		
