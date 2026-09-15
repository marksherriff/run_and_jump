extends SceneTree

var failures := 0

func _initialize() -> void:
	call_deferred("run_checks")

func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)

func frames(count: int) -> void:
	for i in count:
		await physics_frame
		await process_frame

func tap(action: String) -> void:
	Input.action_press(action)
	await frames(1)
	Input.action_release(action)

func run_checks() -> void:
	var game = load("res://Scenes/main.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	var level = game.get_node("Level")
	var player = level.get_node("Gameplay/Player")
	var box = level.get_node("Gameplay/LooperBox")
	check(not player.double_jump and not player.wall_jump and not player.air_dash, "Power-up abilities start disabled")
	await frames(100)
	await tap("jump")
	check(player.velocity.y < 0, "Basic jump remains available")
	await frames(5)
	var base_jump_y: float = player.velocity.y
	await tap("jump")
	check(player.velocity.y > base_jump_y and player.double_jump_count == 0, "Double jump is disabled by default")
	await tap("air_dash")
	check(player.air_dash_count == 0 and absf(player.velocity.x) < player.AIR_DASH_SPEED, "Dash is disabled by default")
	# Later pickups can enable these flags without replacing the player scene.
	player.double_jump = true
	player.air_dash = true
	player.respawn()
	await frames(100)
	check(player.is_on_floor(), "Original spawn settles onto existing terrain")
	await tap("jump")
	check(player.velocity.y < 0 and player.double_jump_count == 0, "Ground jump does not spend double jump")
	await frames(5)
	await tap("jump")
	check(player.double_jump_count == 1, "Air jump spends one double jump")
	await frames(3)
	var previous_y: float = player.velocity.y
	await tap("jump")
	check(player.velocity.y > previous_y, "Third jump is rejected")
	player.change_direction(-1)
	player.change_direction(0)
	check(player.direction == -1, "Releasing direction preserves facing")
	await tap("air_dash")
	check(player.velocity.x == -player.AIR_DASH_SPEED, "Neutral-input dash uses last facing at full speed")
	await tap("air_dash")
	check(player.air_dash_count == 1, "Second air dash is rejected")
	player.respawn()
	await frames(100)
	check(player.double_jump_count == 0 and player.air_dash_count == 0, "Landing restores abilities")
	var view_before: Vector2 = player.get_node("Camera2D").get_screen_center_position()
	await tap("looper")
	check(player.looper_activated and box.visible, "Loop activates")
	var camera = level.get_node("Gameplay/LooperCamera")
	var camera_position: Vector2 = camera.global_position
	check(camera_position.is_equal_approx(view_before), "Activation preserves the current view")
	Input.action_press("move_right")
	await frames(5)
	Input.action_release("move_right")
	check(camera.enabled and not player.get_node("Camera2D").enabled, "Loop selects fixed camera")
	check(camera.global_position == camera_position, "Loop camera remains fixed while moving")
	await tap("looper")
	check(not box.visible and player.get_node("Camera2D").enabled, "Deactivation restores follow camera")

	# Isolate geometry in empty space, with the real scaled player collider.
	player.set_physics_process(false)
	var original_bounds: Rect2 = player.playable_bounds
	player.playable_bounds = Rect2()
	var origin := Vector2(10000, 10000)
	for size in [Vector2(150, 150), Vector2(300, 240)]:
		box.box_size = size
		for edge in [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN, Vector2(-1, -1), Vector2(1, 1)]:
			player.global_position = origin
			player.set_looping(true)
			var body_size: Vector2 = player.collision_rect_at(origin).size
			var reach: Vector2 = (size - body_size) * 0.5 + Vector2.ONE
			player.global_position += edge * reach
			player.velocity = Vector2(123, -234)
			player.double_jump_count = 1
			player.air_dash_count = 1
			box.wrap_player(player)
			var area := Rect2(box.global_position - size * 0.5, size)
			check(area.encloses(player.collision_rect_at(player.global_position)), "Entire collider stays inside loop after edge/corner wrap")
			if edge.x != 0:
				check(signf(player.global_position.x - origin.x) == -edge.x, "Horizontal wrap reaches opposite side")
			else:
				check(is_equal_approx(player.global_position.x, origin.x), "Vertical wrap does not change x")
			if edge.y != 0:
				check(signf(player.global_position.y - origin.y) == -edge.y, "Vertical wrap reaches opposite side")
			else:
				check(is_equal_approx(player.global_position.y, origin.y), "Horizontal wrap does not change y")
			check(player.velocity == Vector2(123, -234), "Wrapping preserves velocity")
			check(player.double_jump_count == 1 and player.air_dash_count == 1, "Wrapping preserves spent abilities")
			check(not player._contacts_valid, "Teleport invalidates old floor/wall contacts")
			player.set_looping(false)

	box.box_size = Vector2(150, 150)
	player.global_position = origin
	player.set_looping(true)
	player.global_position += Vector2(900, -700)
	box.wrap_player(player)
	check(Rect2(box.global_position - box.box_size * 0.5, box.box_size).encloses(player.collision_rect_at(player.global_position)), "Large overshoot still wraps inside box")
	player.set_looping(false)
	player.global_position = origin
	box.box_size = Vector2(10, 10)
	player.set_looping(true)
	check(not player.looper_activated and not box.visible, "Box smaller than player cannot activate")
	box.box_size = Vector2(150, 150)
	player.set_looping(true)
	# Put a wall at the right destination, then cross the left boundary.
	var wall := StaticBody2D.new()
	wall.collision_layer = 2
	var collider := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(30, 100)
	collider.shape = rectangle
	wall.add_child(collider)
	wall.position = origin + Vector2(68, 0)
	root.add_child(wall)
	await frames(2)
	# Create real wall contact to verify wall-jump gating independently.
	player.global_position = origin + Vector2(30, 0)
	player.velocity = Vector2.ZERO
	player.set_physics_process(true)
	Input.action_press("move_right")
	await frames(15)
	Input.action_release("move_right")
	player.set_physics_process(false)
	player.velocity = Vector2.ZERO
	player._contacts_valid = true
	player.double_jump = false
	check(player.is_on_wall_only(), "Wall-jump fixture has wall contact")
	Input.action_press("jump")
	player.handle_jump()
	check(player.velocity.y == 0, "Wall jumping is disabled by default")
	player.wall_jump = true
	player.handle_jump()
	check(player.velocity.y == player.JUMP_VELOCITY, "Enabling wall-jump flag restores wall jumping")
	Input.action_release("jump")
	player.wall_jump = false
	player.double_jump = true
	player.global_position = origin + Vector2(-70, 0)
	player.velocity = Vector2(-300, 40)
	box.wrap_player(player)
	check(player.global_position.x < origin.x, "Blocked destination leaves player at original edge")
	check(player.can_occupy(player.global_position), "Blocked destination does not embed collider")
	check(player.velocity == Vector2(0, 40), "Blocked edge stops only crossing velocity")
	check(player.looper_activated and box.visible, "Blocked edge keeps loop active")
	player.set_looping(false)
	wall.queue_free()
	await frames(2)
	# Bounds participate in destination checks, just like solid terrain.
	player.global_position = origin
	player.playable_bounds = Rect2(origin - Vector2(200, 200), Vector2(230, 400))
	player.set_looping(true)
	player.global_position = origin + Vector2(-70, 0)
	box.wrap_player(player)
	check(player.global_position.x < origin.x, "Out-of-bounds wrap is blocked")
	player.respawn()
	check(not player.looper_activated and not box.visible and not camera.enabled, "Respawning from an active loop clears box and camera")
	player.playable_bounds = original_bounds
	player.set_physics_process(true)
	player.global_position = original_bounds.end + Vector2(500, 500)
	# Disable the box so the world-bounds recovery is exercised directly.
	player.set_looping(false)
	await frames(1)
	check(player.global_position.is_equal_approx(player.spawn_position), "Out-of-bounds player returns to original spawn")
	check(player.velocity == Vector2.ZERO and not player.looper_activated, "Respawn clears motion and loop")
	check(not box.visible and not camera.enabled, "Respawn restores normal camera and hides box")
	print("Player mechanics checks: ", failures, " failures")
	quit(failures)
