extends CharacterBody2D
class_name Uter

const MAX_SCORE = 10000.0
const DECAY_RATE = 0.01
const MAX_ITEMS = 3
const ITEM_BONUS = 0.5
const DEATH_PENALTY = 0.1

var current_score = 0
var final_score = 0
var death_count: int = 0
var items_count: int = 0

@onready var camera: Camera2D = $Camera2D
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer_label: Label = $HUD/Timer
@onready var info_label: Label = $HUD/InfoLabel

@export var unlock_all_abilities: bool = false

var abilities: Dictionary = {}
var ability_descriptions: Dictionary = {}

@export var speed: float = 200.0
@export var jump_force: float = 200.0
@export var dash_force: float = 550.0

var gravity = 10
var jump_count: int = 0
var is_dash_used: bool = false
var can_move: bool = false

var checkpoint: Vector2

var elapsed_time: float = 0.0
var is_timer_running: bool = false

var traffic_lights_colors: Dictionary = {}

func _ready() -> void:
	checkpoint = position
	
	if unlock_all_abilities:
		abilities = {
			"double_jump": true,
			"dash": true
		}
	
	ability_descriptions = {
		"dash" : "Нажмите Shift для совершения рывка (работает даже в воздухе)",
		"double_jump" : "Теперь вы может прыгать целых в два раза больше!"
	}
	
	traffic_lights_colors = {
		"RED" : $HUD/Control/Red,
		"YELLOW" : $HUD/Control/Yellow,
		"GREEN" : $HUD/Control/Green
	}
	
	start_race()
	update_item_display()
	update_death_display()

func start_race():
	switch_traffic_light_color("RED")
	$HUD/Control/Label.text = "Wait"
	await get_tree().create_timer(1.0).timeout
	
	switch_traffic_light_color("YELLOW")
	$HUD/Control/Label.text = "Get ready"
	await get_tree().create_timer(1.0).timeout
	
	switch_traffic_light_color("GREEN")
	$HUD/Control/Label.text = "GO!"
	
	start_timer()
	
	await get_tree().create_timer(1.0).timeout
	turn_off_all_traffic_lights()
	$HUD/Control/Label.text = ""

func switch_traffic_light_color(color: String):
	turn_off_all_traffic_lights()
	
	var light = traffic_lights_colors.get(color)
	if light:
		light.visible = true

func turn_off_all_traffic_lights():
	for light in traffic_lights_colors.values():
		light.visible = false

func start_timer():
	can_move = true
	is_timer_running = true
	elapsed_time = 0.0
	update_timer_display()

func stop_race():
	is_timer_running = false
	var final_score_value = calculate_final_score()
	display_final_score(final_score_value)
	print("=== РЕЗУЛЬТАТЫ ЗАБЕГА ===")
	print("Время: ", timer_label.text)
	print("Базовые очки: ", int(MAX_SCORE * exp(-DECAY_RATE * elapsed_time)))
	print("Собрано арбузов: ", items_count, "/", MAX_ITEMS)
	print("Бонус за арбузы: +", ITEM_BONUS * (items_count / float(MAX_ITEMS)) * 100, "%")
	print("Количество смертей: ", death_count)
	print("Штраф за смерти: -", death_count * DEATH_PENALTY * 100, "%")
	print("Итоговые очки: ", final_score_value)
	
	var finish_menu = load("res://scenes/finish_menu.tscn").instantiate()
	finish_menu.setup(final_score_value, timer_label.text, items_count, death_count)
	get_tree().get_root().add_child(finish_menu)
	
	info_label.text = ""
	timer_label.text = ""
	can_move = false

func update_timer_display():
	var minutes = int(elapsed_time / 60)
	var seconds = int(elapsed_time) % 60
	var milliseconds = int((elapsed_time - int(elapsed_time)) * 100)
	timer_label.text = "%d:%02d:%02d" % [minutes, seconds, milliseconds]

func _process(delta: float) -> void:
	if is_timer_running:
		elapsed_time += delta
		update_timer_display()
		calculate_current_score()

func calculate_current_score():
	var raw_score = MAX_SCORE * exp(-DECAY_RATE * elapsed_time)
	current_score = max(0, int(raw_score))
	#display_current_score()

func display_current_score():
	info_label.text = "Current score: " + str(current_score)

func calculate_final_score():
	var base_score = MAX_SCORE * exp(-DECAY_RATE * elapsed_time)
	
	var item_multiplier = 1.0 + ITEM_BONUS * (items_count / float(MAX_ITEMS))
	var death_penalty_multiplier = 1.0 - (death_count * DEATH_PENALTY)
	death_penalty_multiplier = max(0, death_penalty_multiplier)  # не уходим в минус
	
	final_score = int(base_score * item_multiplier * death_penalty_multiplier)
	final_score = max(0, final_score)  # защита от отрицательных значений
	
	return final_score

func die():
	death_count += 1
	camera.screen_shake(5, 0.2)
	anim.self_modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	anim.self_modulate = Color.WHITE
	position = checkpoint
	update_death_display()

func save(new_checkpoint):
	checkpoint = new_checkpoint

func has_ability(ability: String):
	return abilities.get(ability, false)

func add_ability(ability: String):
	if has_ability(ability):
		return
	
	abilities.set(ability, true)
	display_ability_info(ability)

func add_item(num):
	items_count += num
	update_item_display()

func display_final_score(value):
	info_label.text = "Final Score: " + str(value)

func update_item_display():
	$HUD/ItemCounter/Label.text = "x" + str(items_count)

func update_death_display():
	$HUD/DeathCounter/Label.text = "x" + str(death_count)

func display_ability_info(ability: String):
	#var ability_name = ability.capitalize()
	var ability_description = ability_descriptions.get(ability)
	
	info_label.text = "Получен " + ability + "\n" + ability_description
	
	await get_tree().create_timer(3.0).timeout
	info_label.text = ""
