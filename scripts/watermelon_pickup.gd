extends AnimatedSprite2D

@export var value: int = 1

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Uter:
		body.add_item(value)
		queue_free()
