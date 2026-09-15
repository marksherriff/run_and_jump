extends Area2D

@export var box_size := Vector2(150, 150)
var player: CharacterBody2D

func _ready() -> void:
	process_physics_priority = 1
	disable_box()

func _draw() -> void:
	var half := box_size * 0.5
	for x in range(0, int(box_size.x), 10):
		draw_rect(Rect2(Vector2(x, 0) - half, Vector2(5, 2)), Color.WHITE)
		draw_rect(Rect2(Vector2(x, box_size.y) - half, Vector2(5, 2)), Color.WHITE)
	for y in range(0, int(box_size.y), 10):
		draw_rect(Rect2(Vector2(0, y) - half, Vector2(2, 5)), Color.WHITE)
		draw_rect(Rect2(Vector2(box_size.x, y) - half, Vector2(2, 5)), Color.WHITE)

func _physics_process(_delta: float) -> void:
	if not visible or not is_instance_valid(player):
		return
	var offset := player.global_position - global_position
	var half := box_size * 0.5
	var destination := offset
	# Wrap the crossed axis, preserving overshoot and velocity.
	if offset.x < -half.x or offset.x > half.x:
		destination.x = wrapf(offset.x, -half.x, half.x)
	if offset.y < -half.y or offset.y > half.y:
		destination.y = wrapf(offset.y, -half.y, half.y)
	if destination == offset:
		return
	var shape: CollisionShape2D = player.get_node("CollisionBox")
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = shape.shape
	query.transform = shape.global_transform
	query.transform.origin += destination - offset
	query.collision_mask = player.collision_mask
	query.exclude = [player.get_rid()]
	if get_world_2d().direct_space_state.intersect_shape(query).is_empty():
		player.global_position = global_position + destination
	else:
		# Block an unsafe destination instead of embedding the player in a wall.
		player.global_position = global_position + offset.clamp(-half, half)

func enable_box() -> void:
	show()
	queue_redraw()

func disable_box() -> void:
	hide()
