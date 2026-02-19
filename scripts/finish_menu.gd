extends CanvasLayer

func setup(result: int, time: String, item_count: int, death_count: int):
	$Control/RaceResults.text = "Время забега: " + time + "\n" + "Собрано арбузов: " + str(item_count) + "\n" + "Смертей всего: " + str(death_count) + "\n\n" + "Итоговый результат: " + str(result)

func _on_button_pressed() -> void:
	#Тут должен быть HTTP-запрос на получение уровня в practice_mode
	
	# Но пока что просто перезапуск уровня level01
	get_tree().change_scene_to_file("res://levels/level_01.tscn")
	queue_free()
