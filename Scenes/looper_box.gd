extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		print(body.position, body.velocity)
		if body.velocity.x > 0:
			body.set_position(Vector2(body.position.x - 150, body.position.y))
		elif body.velocity.x < 0:
			body.set_position(Vector2(body.position.x + 150, body.position.y))
		if body.velocity.y < 0:
			body.set_position(Vector2(body.position.x, body.position.y + 150))
		elif body.velocity.y > 0:
			body.set_position(Vector2(body.position.x, body.position.y - 150))

func enable_box() -> void:
	print("enable")
	visible = true
	$CollisionShape2D.disabled = false
	$Sprite2D.visible = true
	
func disable_box() -> void:
	print("disable")
	visible = false
	$CollisionShape2D.disabled = true
	$Sprite2D.visible = false
