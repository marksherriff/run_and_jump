extends SceneTree

func _initialize() -> void:
	call_deferred("run_checks")

func run_checks() -> void:
	var template = load("res://Scenes/Levels/base_level.tscn").instantiate()
	template.position = Vector2(100, 200)
	template.get_node("World/SpawnPoint").position = Vector2(64, 120)
	template.level_bounds = Rect2(-100, -100, 400, 400)
	root.add_child(template)
	var player = template.get_node("Gameplay/Player")
	assert(player.global_position == Vector2(164, 320), "Level spawn positions the player")
	assert(player.spawn_position == player.global_position, "Recovery uses the level's spawn")
	assert(player.playable_bounds == Rect2(0, 100, 400, 400), "Explicit bounds follow level position")
	assert(template.get_node("World/TileMapLayer").get_used_cells().is_empty(), "Base template starts unpainted")
	assert(player.loop_box == template.get_node("Gameplay/LooperBox"), "Standalone level wires looping")
	assert(not player.double_jump and not player.wall_jump and not player.air_dash, "Template inherits disabled abilities")
	template.queue_free()
	await process_frame
	var example = load("res://Scenes/Levels/example_level.tscn").instantiate()
	root.add_child(example)
	assert(not example.get_node("World/TileMapLayer").get_used_cells().is_empty(), "Example retains painted terrain")
	assert(example.get_node("Gameplay/Player").spawn_position == Vector2.ZERO, "Example retains original spawn")
	assert(example.get_node("Gameplay/Player").playable_bounds.has_area(), "Painted level derives recovery bounds")
	print("Level structure checks passed")
	quit()
