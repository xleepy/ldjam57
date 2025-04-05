extends CharacterBody2D
	


var move_actions = []

var directionsMap: Dictionary = {
	'move_up': Vector2.UP,
	'move_down': Vector2.DOWN,
	'move_right': Vector2.RIGHT,
	'move_left': Vector2.LEFT
}

func _ready() -> void:
	var floor: TileMapLayer = $"../Floor"
	var used_cells = floor.get_used_cells()
	
	print(used_cells)
	var all_actions: Array = InputMap.get_actions()
	for action in all_actions:
		if action.begins_with("move_"):
			move_actions.append(action)
			

func move(direction: Vector2) -> void:
	var space_rid = get_world_2d().space
	var space_state = PhysicsServer2D.space_get_direct_state(space_rid)
	var query = PhysicsRayQueryParameters2D.create(global_position, global_position + Global.tile_size * direction)
	var result = space_state.intersect_ray(query)
	if result:
		if result.collider.is_in_group("Wall"):
			return
	
	position += Global.tile_size * direction

func _physics_process(delta: float) -> void:
	for action in move_actions:
		if Input.is_action_just_pressed(action):
			var move_vector = directionsMap[action]
			move(move_vector)
