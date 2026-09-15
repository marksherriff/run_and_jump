@tool
extends Node2D

func _draw() -> void:
	draw_rect(Rect2(-2048, -2048, 4096, 4096), Color("172c48"))
	for y in range(0, 640, 8):
		var color := Color("589bce").lerp(Color("b5e4eb"), float(y) / 640.0)
		draw_rect(Rect2(0, y, 640, 8), color)
	for cloud in [Vector2(65, 120), Vector2(370, 90), Vector2(170, 265), Vector2(450, 315)]:
		_draw_cloud(cloud)

func _draw_cloud(origin: Vector2) -> void:
	draw_rect(Rect2(origin + Vector2(0, 16), Vector2(112, 24)), Color("c9e5f2"))
	draw_rect(Rect2(origin + Vector2(16, 0), Vector2(40, 32)), Color("effaff"))
	draw_rect(Rect2(origin + Vector2(48, 8), Vector2(40, 24)), Color("effaff"))
	draw_rect(Rect2(origin + Vector2(8, 16), Vector2(96, 16)), Color("effaff"))
