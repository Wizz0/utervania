extends CharacterBody2D
class_name Uter

@onready var camera: Camera2D = $Camera2D

@export var speed: float = 200.0
@export var jump_force: float = 200.0
@export var dash_force: float = 550.0
var gravity = 10
var jump_count: int = 0
var is_dash_used: bool = false
var can_move: bool = false

var checkpoint: Vector2

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer_label: Label = $HUD/Timer

@export var unlock_all_abilities: bool = false

var abilities: Dictionary = {}
var watermelons: int = 0

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
	
	traffic_lights_colors = {
		"RED" : $HUD/Control/Red,
		"YELLOW" : $HUD/Control/Yellow,
		"GREEN" : $HUD/Control/Green
	}
	
	start_race()
	update_watermelon_display()

func start_race():
	switch_traffic_light_color("RED")
	await get_tree().create_timer(1.0).timeout
	
	switch_traffic_light_color("YELLOW")
	await get_tree().create_timer(1.0).timeout
	
	switch_traffic_light_color("GREEN")
	
	start_timer()
	
	await get_tree().create_timer(1.0).timeout
	turn_off_all_traffic_lights()

func switch_traffic_light_color(color: String):
	turn_off_all_traffic_lights()
	
	var light = traffic_lights_colors.get(color)
	if light:
		light.visible = true

func turn_off_all_traffic_lights():
	for light in traffic_lights_colors.values():
		light.visible = false

func _process(delta: float) -> void:
	if is_timer_running:
		elapsed_time += delta
		update_timer_display()

func die():
	camera.screen_shake(5, 0.2)
	position = checkpoint

func save(new_checkpoint):
	checkpoint = new_checkpoint

func has_ability(ability: String):
	return abilities.get(ability, false)
	print(abilities)

func add_ability(ability: String):
	if has_ability(ability):
		return
	
	abilities.set(ability, true)
	print(abilities)

func add_watermelon(num: int = 1):
	watermelons += num
	update_watermelon_display()

func start_timer():
	can_move = true
	is_timer_running = true
	elapsed_time = 0.0
	update_timer_display()

func update_timer_display():
	var minutes = int(elapsed_time / 60)
	var seconds = int(elapsed_time) % 60
	var milliseconds = int((elapsed_time - int(elapsed_time)) * 100)
	timer_label.text = "%d:%02d:%02d" % [minutes, seconds, milliseconds]

func stop_race():
	is_timer_running = false

func update_watermelon_display():
	$HUD/WatermelonCounter/Label.text = "x" + str(watermelons)
