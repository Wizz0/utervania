extends CanvasLayer


func _on_play_button_pressed() -> void:
	# Здесь должен быть HTTP-запрос, который просит у сервера сегодняшний уровень
	
	# Но пока просто загружаем level01
	get_tree().change_scene_to_file("res://levels/level_01.tscn")
