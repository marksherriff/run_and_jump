extends CharacterBody2D

signal hit
signal coin_collected
signal camera_switched

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const AIR_DASH_SPEED = 700.0
const ACCELERATION = 1000.0
const FRICTION = 1500.0

var coins = 0
var health = 3
var direction = 1

@export_group("Abilities")
@export var double_jump := false
@export var wall_jump := false
@export var air_dash := false

var double_jump_count = 0
var double_jump_max = 1
var air_dash_count = 0
var air_dash_max = 1
var looper = true
var looper_activated = false

# The level supplies the loop and safe-play bounds without coupling this scene
# to one particular TileMap or node hierarchy.
var loop_box: Area2D
var playable_bounds := Rect2()
var spawn_position := Vector2.ZERO
var _contacts_valid := true

func _ready() -> void:
	spawn_position = global_position

func _physics_process(delta: float) -> void:
	var grounded := _contacts_valid and is_on_floor()
	if grounded:
		double_jump_count = 0
		air_dash_count = 0
	var input_x := Input.get_axis("move_left", "move_right")
	change_direction(input_x)
	handle_gravity(delta)
	handle_move(Vector2(input_x, 0), delta)
	handle_jump()
	# Apply the dash after normal acceleration so the first frame gets its
	# full impulse, including when no direction is currently held.
	handle_air_dash()
	handle_looper()
	move_and_slide()
	_contacts_valid = true
	if looper_activated and is_instance_valid(loop_box):
		loop_box.wrap_player(self)
	if playable_bounds.has_area() and not playable_bounds.encloses(collision_rect_at(global_position)):
		respawn()
	update_animation()

func handle_gravity(delta: float) -> void:
	if not (_contacts_valid and is_on_floor()):
		velocity += get_gravity() * delta

func handle_jump() -> void:
	if not Input.is_action_just_pressed("jump"):
		return
	if _contacts_valid and is_on_floor():
		velocity.y = JUMP_VELOCITY
	elif wall_jump and _contacts_valid and is_on_wall_only():
		velocity.y = JUMP_VELOCITY
	elif double_jump and double_jump_count < double_jump_max:
		velocity.y = JUMP_VELOCITY
		double_jump_count += 1

func handle_air_dash() -> void:
	if Input.is_action_just_pressed("air_dash") and not (_contacts_valid and is_on_floor()) and air_dash and air_dash_count < air_dash_max:
		air_dash_count += 1
		velocity.x = direction * AIR_DASH_SPEED

func handle_move(input_vector: Vector2, delta: float) -> void:
	var rate := ACCELERATION if input_vector.x != 0 else FRICTION
	velocity.x = move_toward(velocity.x, SPEED * input_vector.x, rate * delta)

func update_animation() -> void:
	$AnimatedSprite2D.flip_h = direction < 0
	if _contacts_valid and is_on_floor():
		$AnimatedSprite2D.play("run" if absf(velocity.x) > 0.1 else "idle")
	else:
		$AnimatedSprite2D.play("jump" if velocity.y < 0 else "fall")

func _on_coin_collected() -> void:
	coins += 1

func change_direction(value: float) -> void:
	if value != 0:
		direction = int(signf(value))

func get_coins() -> int:
	return coins

func handle_looper() -> void:
	if Input.is_action_just_pressed("looper") and looper:
		set_looping(not looper_activated)

func set_looping(active: bool) -> void:
	if active == looper_activated:
		return
	if active:
		if not is_instance_valid(loop_box) or not loop_box.activate(self):
			return
	elif is_instance_valid(loop_box):
		loop_box.disable_box()
	looper_activated = active
	# Observers always see the new state, including during respawn.
	camera_switched.emit()

func teleport_to(destination: Vector2) -> void:
	global_position = destination
	# move_and_slide's floor/wall contacts describe the old location.
	# Do not grant fresh jumps or wall jumps from those stale contacts.
	_contacts_valid = false
	reset_physics_interpolation()

func respawn() -> void:
	set_looping(false)
	teleport_to(spawn_position)
	velocity = Vector2.ZERO
	double_jump_count = 0
	air_dash_count = 0

func collision_rect_at(destination: Vector2) -> Rect2:
	var shape: CollisionShape2D = $CollisionBox
	var rectangle: RectangleShape2D = shape.shape
	var size := rectangle.size * shape.global_scale.abs()
	var center := shape.global_position + destination - global_position
	return Rect2(center - size * 0.5, size)

func can_occupy(destination: Vector2) -> bool:
	if playable_bounds.has_area() and not playable_bounds.encloses(collision_rect_at(destination)):
		return false
	var shape: CollisionShape2D = $CollisionBox
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = shape.shape
	query.transform = shape.global_transform
	query.transform.origin += destination - global_position
	query.collision_mask = collision_mask
	query.exclude = [get_rid()]
	return get_world_2d().direct_space_state.intersect_shape(query).is_empty()
