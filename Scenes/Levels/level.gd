extends Node2D

# Bounds use level-local coordinates so moving a level instance moves its bounds.
# Leave empty to derive them from painted terrain.
@export var level_bounds := Rect2()
@export var recovery_margin := 128.0

@onready var player = $Gameplay/Player
@onready var loop_box = $Gameplay/LooperBox
@onready var loop_camera: Camera2D = $Gameplay/LooperCamera
@onready var follow_camera: Camera2D = $Gameplay/Player/Camera2D

func _ready() -> void:
	player.global_position = $World/SpawnPoint.global_position
	player.spawn_position = player.global_position
	player.loop_box = loop_box
	player.playable_bounds = _get_playable_bounds()
	_on_player_camera_switched()
	$HUD.update_coins(player.get_coins())

func _get_playable_bounds() -> Rect2:
	if level_bounds.has_area():
		return global_transform * level_bounds
	var bounds := Rect2()
	# Include every terrain layer added under World, including nested layers.
	for node in $World.find_children("*", "TileMapLayer", true, false):
		var map := node as TileMapLayer
		var used := map.get_used_rect()
		if not used.has_area():
			continue
		var tile_size := Vector2(map.tile_set.tile_size)
		var local_rect := Rect2(Vector2(used.position) * tile_size, Vector2(used.size) * tile_size)
		var world_rect: Rect2 = map.global_transform * local_rect
		bounds = bounds.merge(world_rect) if bounds.has_area() else world_rect
	if not bounds.has_area():
		# An unpainted template still has finite recovery bounds.
		bounds = Rect2(player.global_position - Vector2(256, 256), Vector2(512, 512))
	return bounds.expand(player.global_position).grow(recovery_margin)

func _on_player_coin_collected() -> void:
	$HUD.update_coins(player.get_coins())

func _on_player_camera_switched() -> void:
	if player.looper_activated:
		loop_camera.global_position = follow_camera.get_screen_center_position()
		loop_camera.zoom = follow_camera.zoom
		follow_camera.enabled = false
		loop_camera.enabled = true
	else:
		loop_camera.enabled = false
		follow_camera.enabled = true
		follow_camera.reset_smoothing()
