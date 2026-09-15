@tool
extends Area2D

# One size drives both the visible rectangle and the wrapping boundary.
# A larger box can later be supplied by changing this value before activation.
@export var box_size := Vector2(150, 150):
	set(value):
		box_size = Vector2(maxf(value.x, 1.0), maxf(value.y, 1.0))
		if is_node_ready():
			_update_size()

var _last_safe_position := Vector2.ZERO
const EDGE_MARGIN := 0.1

func _ready() -> void:
	monitoring = false
	monitorable = false
	_update_size()
	if not Engine.is_editor_hint():
		disable_box()

func _update_size() -> void:
	$Sprite2D.scale = box_size / $Sprite2D.texture.get_size()
	var rectangle := RectangleShape2D.new()
	rectangle.size = box_size
	$CollisionShape2D.shape = rectangle
	$CollisionShape2D.position = Vector2.ZERO

func activate(player: CharacterBody2D) -> bool:
	var body_rect: Rect2 = player.collision_rect_at(player.global_position)
	if box_size.x <= body_rect.size.x + EDGE_MARGIN * 2 or box_size.y <= body_rect.size.y + EDGE_MARGIN * 2:
		return false
	if not player.can_occupy(player.global_position):
		return false
	global_position = body_rect.get_center()
	_last_safe_position = player.global_position
	enable_box()
	return true

func wrap_player(player: CharacterBody2D) -> void:
	if not visible:
		return
	var body_rect: Rect2 = player.collision_rect_at(player.global_position)
	var center_offset: Vector2 = body_rect.get_center() - player.global_position
	var world_size := box_size * global_scale.abs()
	# Keep the whole collider inside the dotted rectangle, not just its origin.
	var minimum: Vector2 = global_position - world_size * 0.5 + body_rect.size * 0.5 - center_offset + Vector2.ONE * EDGE_MARGIN
	var maximum: Vector2 = global_position + world_size * 0.5 - body_rect.size * 0.5 - center_offset - Vector2.ONE * EDGE_MARGIN
	if minimum.x >= maximum.x or minimum.y >= maximum.y:
		player.set_looping(false)
		return
	var destination := player.global_position
	var crossed_x := destination.x < minimum.x or destination.x > maximum.x
	var crossed_y := destination.y < minimum.y or destination.y > maximum.y
	if not crossed_x and not crossed_y:
		_last_safe_position = destination
		return
	if crossed_x:
		destination.x = wrapf(destination.x, minimum.x, maximum.x)
	if crossed_y:
		destination.y = wrapf(destination.y, minimum.y, maximum.y)
	if player.can_occupy(destination):
		player.teleport_to(destination)
		_last_safe_position = destination
		return
	# A blocked edge is solid. Clamp at that edge if safe; otherwise return to
	# the last contained position (important at corners next to terrain).
	var stopped: Vector2 = player.global_position.clamp(minimum, maximum)
	if not player.can_occupy(stopped):
		stopped = _last_safe_position
	player.teleport_to(stopped)
	if crossed_x:
		player.velocity.x = 0
	if crossed_y:
		player.velocity.y = 0

func enable_box() -> void:
	show()

func disable_box() -> void:
	hide()
