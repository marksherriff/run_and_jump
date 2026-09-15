extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_player_coin_collected() -> void:
	$HUD.update_coins($Player.get_coins())


func _on_player_camera_switched() -> void:
	if $LooperCamera.enabled:
		$LooperCamera.enabled = false
		$LooperBox.disable_box()
	else:
		$LooperCamera.position = $Player.position
		$LooperBox.position = $Player.position
		$LooperCamera.enabled = true
		$LooperBox.enable_box()
