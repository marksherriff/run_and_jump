extends CharacterBody2D

signal hit
signal coin_collected
signal camera_switched

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const AIR_DASH_SPEED = 700.0
const ACCELERATION = 1000.0
const FRICTION = 1500.0


# Player status
var coins = 0
var health = 3
var direction = 1

# Power-ups
var double_jump = true
var double_jump_count = 0
var double_jump_max = 1

var air_dash = true
var air_dash_count = 0
var air_dash_max = 1

var looper = true
var looper_activated = false


func _physics_process(delta: float) -> void:
	
	handle_gravity(delta)
	handle_jump()
	handle_air_dash()
	handle_looper()
	
	var input_vector: Vector2 = Vector2.ZERO
	input_vector.x = Input.get_axis("move_left", "move_right")
	handle_move(input_vector, delta)
	change_direction(input_vector.x)

	move_and_slide()
	
func handle_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

func handle_jump() -> void:
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
		elif not is_on_wall() and double_jump and double_jump_count < double_jump_max:
			velocity.y = JUMP_VELOCITY
			double_jump_count += 1
		elif is_on_wall_only():
			velocity.y = JUMP_VELOCITY
			
			
func handle_air_dash() -> void:
	if Input.is_action_just_pressed("air_dash") and not is_on_floor() and air_dash and air_dash_count < air_dash_max:
		air_dash_count += 1
		velocity.x = direction * AIR_DASH_SPEED
		
func handle_move(input_vector: Vector2, delta: float) -> void:
	if input_vector.x != 0:
		velocity.x = move_toward(velocity.x, SPEED * input_vector.x, ACCELERATION * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
	
	if velocity.x != 0 and is_on_floor():
		$AnimatedSprite2D.play("run")
		$AnimatedSprite2D.flip_h = velocity.x < 0
		double_jump_count = 0
		air_dash_count = 0
	elif velocity.x == 0 and is_on_floor():
		$AnimatedSprite2D.play("idle")
		double_jump_count = 0
		air_dash_count = 0
	elif velocity.y < 0 and not is_on_floor():
		$AnimatedSprite2D.play("jump")
		$AnimatedSprite2D.flip_h = velocity.x < 0
	elif velocity.y > 0 and not is_on_floor():
		$AnimatedSprite2D.play("fall")
		$AnimatedSprite2D.flip_h = velocity.x < 0
		

func _on_coin_collected() -> void:
	coins += 1
	
func change_direction(value: float) -> void:
	direction = sign(value)
	
func get_coins() -> int:
	return coins
	
func handle_looper() -> void:
	if Input.is_action_just_pressed("looper") and looper:
		if looper_activated:
			$Camera2D.enabled = true
			camera_switched.emit()
			looper_activated = false
		else:
			$Camera2D.enabled = false
			camera_switched.emit()
			looper_activated = true
