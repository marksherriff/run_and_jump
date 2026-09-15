extends Area2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimatedSprite2D.play("default")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	body.coin_collected.emit()
	$CollisionShape2D.set_deferred("disabled", true)
	$AudioStreamPlayer2D.play()
	$AnimatedSprite2D.hide()
	await get_tree().create_timer(0.5).timeout
	queue_free()
	
