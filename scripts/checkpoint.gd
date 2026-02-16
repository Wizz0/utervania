extends Sprite2D

func _ready() -> void:
	$Label.text = ""

func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body is Uter and body.checkpoint != position:
		body.save(position)
		display_text()
		glow()
	
func display_text():
	$Label.text = "Чекпоинт"
	await get_tree().create_timer(2.0).timeout
	$Label.text = ""

func glow():
	# Создаем твин для плавной анимации
	var tween = create_tween().set_parallel(true)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	# Пульсирующее свечение - несколько колебаний
	tween.tween_property($PointLight2D, "energy", 4.0, 0.3)
	tween.tween_property($PointLight2D, "energy", 2.5, 0.3)
	tween.tween_property($PointLight2D, "energy", 3.5, 0.2)
	tween.tween_property($PointLight2D, "energy", 2.0, 0.2)
	tween.tween_property($PointLight2D, "energy", 3.0, 0.2)
	tween.tween_property($PointLight2D, "energy", 1.8, 0.2)
	tween.tween_property($PointLight2D, "energy", 2.5, 0.2)
	
	# Возвращаем к базовому значению
	await get_tree().create_timer(1.8).timeout
	tween.kill()
	
	var return_tween = create_tween()
	return_tween.tween_property($PointLight2D, "energy", 0.5, 0.5)
