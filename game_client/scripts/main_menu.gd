extends CanvasLayer

@onready var http_request: HTTPRequest = $HTTPRequest

func _ready():
	# Подключаем сигнал завершения запроса
	http_request.request_completed.connect(_on_request_completed)

func _on_request_completed(result, response_code, headers, body):
	print("Ответ от сервера. Код: ", response_code)
	
	if response_code == 200:
		# Успешно получили файл
		print("Файл уровня получен, размер: ", body.size(), " байт")
		
		# Сохраняем файл во временную папку
		var level_path = "user://current_level.tscn"
		var file = FileAccess.open(level_path, FileAccess.WRITE)
		if file:
			file.store_buffer(body)
			file.close()
			print("Файл сохранен в: ", level_path)
			
			# Загружаем сохраненный уровень
			get_tree().change_scene_to_file(level_path)
		else:
			print("Не удалось сохранить файл")
			load_local_level()
	else:
		# Ошибка сервера
		print("Ошибка сервера: ", response_code)
		print("Ответ: ", body.get_string_from_utf8())
		load_local_level()

func _on_play_button_pressed() -> void:
	print("Запрашиваем уровень с сервера...")
	
	# URL твоего бэкенда (локальный или удаленный)
	var url = "http://localhost:8000/daily/"
	
	# Отправляем GET запрос
	var error = http_request.request(url)
	
	if error != OK:
		print("Ошибка отправки запроса: ", error)
		# Если не работает - грузим локальный уровень
		load_local_level()

func load_local_level():
	# Заглушка на случай, если сервер не работает
	print("Загружаем локальный уров ень level_01")
	get_tree().change_scene_to_file("res://levels/level_01.tscn")
