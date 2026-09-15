extends Node2D

var completed := false

func _ready() -> void:
	$LooperBox.player = $Player
	$Exit.body_entered.connect(_on_exit_entered)
	$HUD/Complete/Panel/Replay.pressed.connect(_restart)
	get_viewport().size_changed.connect(_fit_camera)
	_fit_camera()

func _fit_camera() -> void:
	var size := get_viewport_rect().size
	var zoom_factor := minf(size.x, size.y) / 704.0
	for camera in [$Player/Camera2D, $LooperCamera]:
		camera.zoom = Vector2.ONE * zoom_factor
		camera.limit_left = -32
		camera.limit_top = -32
		camera.limit_right = 672
		camera.limit_bottom = 672

func _on_player_camera_switched() -> void:
	if $LooperCamera.enabled:
		$LooperCamera.enabled = false
		$LooperBox.disable_box()
	else:
		$LooperCamera.global_position = $Player/Camera2D.get_screen_center_position()
		$LooperBox.global_position = $Player.global_position
		$LooperCamera.enabled = true
		$LooperBox.enable_box()

func _on_exit_entered(body: Node2D) -> void:
	if body != $Player or completed:
		return
	completed = true
	$Player.set_physics_process(false)
	$Player.velocity = Vector2.ZERO
	$Player/AnimatedSprite2D.play("idle")
	$LooperBox.disable_box()
	$HUD/Complete.show()
	$HUD/Complete/Panel/Replay.grab_focus()

func _restart() -> void:
	get_tree().reload_current_scene()
