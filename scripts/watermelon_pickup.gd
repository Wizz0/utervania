extends AnimatedSprite2D

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Uter:
		body.add_watermelon()
		queue_free()
