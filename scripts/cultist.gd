extends CharacterBody2D

var movement_speed: float = Global.tile_size * 2 
var detection_range: float = Global.tile_size * 2   # Range to detect player 16 * 2

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var animation: AnimatedSprite2D = $AnimatedSprite2D

var state = 'idle'

func random_position() -> Vector2:
	var viewport_rect = get_viewport_rect().size
	var randX = randf_range(0, viewport_rect.x)
	var randY = randf_range(0, viewport_rect.y)
	return Vector2(randX, randY)

func _ready():
	# These values need to be adjusted for the actor's speed
	# and the navigation layout.
	navigation_agent.path_desired_distance = 2.0
	navigation_agent.target_desired_distance = 2.0
	# keep agent on same place for now 
	actor_setup.call_deferred()
	var possible_position = random_position()
	make_path(possible_position)

func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame

func _physics_process(delta):
	var player: Player = get_tree().get_first_node_in_group("Player")
	if not player:
		return;
	# Calculate distance to player
	var distance_to_player = global_position.distance_to(player.global_position)
	var next_position: Vector2
	if not player.is_hidden and distance_to_player <= detection_range:
		# Player is within detection range, follow them
		next_position = player.global_position
	else:
		next_position = navigation_agent.get_next_path_position()
		# Player is out of range, go back to original position
	var direction = position.direction_to(next_position)
	if direction.x < 0:
		animation.scale.x = -1.0
	elif direction.x > 0:
		animation.scale.x = 1
	velocity = direction * movement_speed
	if state == 'walk':
		move_and_slide()

func set_movement_target(movement_target: Vector2):
	navigation_agent.target_position = movement_target


func _on_area_2d_body_entered(body: Node2D) -> void:
	pass # Replace with function body.


func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = velocity.move_toward(safe_velocity, 100)
	move_and_slide()
	
func make_path(position: Vector2):
	navigation_agent.target_position = position


func _on_navigation_agent_2d_navigation_finished() -> void:
	animation.play("idle")
	state = 'idle'
	$Timer.start(1)


func _on_timer_timeout() -> void:
	var possible_position = random_position()
	make_path(possible_position) 


func _on_navigation_agent_2d_path_changed() -> void:
	animation.play("walk")
	state = 'walk'
