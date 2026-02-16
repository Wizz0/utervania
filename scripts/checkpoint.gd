extends Sprite2D

func _ready() -> void:
	$Label.text = ""

func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body is Uter and body.checkpoint != position:
		body.save(position)
		display_text()	
	
func display_text():
	$Label.text = "Чекпоинт"
	await get_tree().create_timer(2.0).timeout
	$Label.text = ""
