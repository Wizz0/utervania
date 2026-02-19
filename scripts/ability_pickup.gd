extends AnimatedSprite2D

@export var ability_to_give: String

var time: float = 0.0

func _process(delta: float) -> void:
	# свечение
	time += delta
	
	var scale_value = 8.0 + sin(time * 2.5) * 3.0
	$PointLight2D.texture_scale = scale_value

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Uter:
		body.add_ability(ability_to_give)
		queue_free()
