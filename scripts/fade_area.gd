extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body is Uter:
		if get_parent():
			var parent = get_parent()
			parent.modulate.a = 0.1
