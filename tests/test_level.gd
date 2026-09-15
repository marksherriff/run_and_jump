extends SceneTree

var failures := 0

func _initialize() -> void:
	call_deferred("_run")

func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)

func frames(count: int) -> void:
	for i in count:
		await physics_frame
		await process_frame

func _run() -> void:
	var level = load("res://Scenes/main.tscn").instantiate()
	root.add_child(level)
	current_scene = level
	var player = level.get_node("Player")
	var box = level.get_node("LooperBox")
	await frames(10)
	check(player.is_on_floor(), "Player starts on the floor")
	Input.action_press("move_right")
	await frames(90)
	Input.action_release("move_right")
	check(player.position.x < 304, "Walking cannot cross the wall")
	Input.action_press("jump")
	await frames(1)
	Input.action_release("jump")
	await frames(20)
	Input.action_press("jump")
	await frames(1)
	Input.action_release("jump")
	await frames(90)
	check(player.position.x < 304, "Double jump stays on the starting side")
	Input.action_press("looper")
	await frames(1)
	Input.action_release("looper")
	check(box.visible and level.get_node("LooperCamera").enabled, "Loop activates and locks camera")
	Input.action_press("move_left")
	for i in 90:
		await frames(1)
		if player.position.x > 336:
			break
	Input.action_release("move_left")
	check(player.position.x > 336, "Walking left through loop reaches far side of wall")
	Input.action_press("looper")
	await frames(1)
	Input.action_release("looper")
	check(not box.visible and player.get_node("Camera2D").enabled, "Loop deactivates")
	Input.action_press("move_right")
	await frames(100)
	Input.action_release("move_right")
	check(level.completed, "Exit completes the level")
	check(not player.is_physics_processing(), "Completion stops gameplay")
	check(level.get_node("HUD/Complete").visible, "Completion screen appears")
	# Isolate boundary math in open air on the left side of the room.
	box.global_position = Vector2(160, 300)
	box.enable_box()
	var cases := [
		[Vector2(-76, 0), Vector2(74, 0)],
		[Vector2(76, 0), Vector2(-74, 0)],
		[Vector2(0, -76), Vector2(0, 74)],
		[Vector2(0, 76), Vector2(0, -74)],
		[Vector2(-76, 76), Vector2(74, -74)],
	]
	for pair in cases:
		player.global_position = box.global_position + pair[0]
		player.velocity = Vector2(100, 200)
		box._physics_process(0.0)
		check(player.global_position.is_equal_approx(box.global_position + pair[1]), "Correct edge/corner destination")
		check(player.velocity == Vector2(100, 200), "Wrapping preserves momentum")
	box.global_position = Vector2(244, 300)
	player.global_position = Vector2(168, 300)
	box._physics_process(0.0)
	check(player.global_position.x < 304, "Wrapping cannot embed the player in the divider")
	level._restart()
	await frames(5)
	check(not current_scene.completed, "Replay resets completion")
	check(current_scene.get_node("Player").position.x < 100, "Replay resets spawn")
	check(not current_scene.get_node("LooperBox").visible, "Replay resets looping")
	print("Level integration checks: ", failures, " failures")
	quit(failures)
