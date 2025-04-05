extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var player_camera: Camera2D = $Player/Camera2D


func zoom_camera_to_tilemap_bounds():
	var tilemap_layer = $TileMapLayer
	# Get used cells to determine bounds
	var used_cells = tilemap_layer.get_used_cells()
	
	if used_cells.size() == 0:
		return  # No tiles to zoom to
	
	# Initialize bounds with the first cell
	var min_x = used_cells[0].x
	var max_x = used_cells[0].x
	var min_y = used_cells[0].y
	var max_y = used_cells[0].y
	
	# Find the boundaries of the used cells
	for cell in used_cells:
		min_x = min(min_x, cell.x)
		max_x = max(max_x, cell.x)
		min_y = min(min_y, cell.y)
		max_y = max(max_y, cell.y)
	
	# Convert tile coordinates to world coordinates
	var cell_size = 16
	var world_min = Vector2(min_x, min_y) * cell_size
	var world_max = Vector2(max_x + 1, max_y + 1) * cell_size
	
	# Calculate tilemap size
	var tilemap_size = world_max - world_min
	
	# Calculate zoom level to fit the tilemap
	var viewport_size = get_viewport_rect().size
	var zoom_level = max(tilemap_size.x / viewport_size.x, tilemap_size.y / viewport_size.y)
	
	# Add some padding (optional)
	zoom_level *= 1.1
	
	# Apply zoom to camera
	player_camera.zoom = Vector2(zoom_level, zoom_level)
	
	# Center camera on tilemap
	player_camera.position = world_min + tilemap_size / 2
	
func _ready() -> void:
	pass
	#zoom_camera_to_tilemap_bounds()
