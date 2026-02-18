extends CharacterBody2D
class_name Uter

@onready var camera: Camera2D = $Camera2D

@export var speed: float = 200.0
@export var jump_force: float = 200.0
@export var dash_force: float = 550.0
var gravity = 10
var jump_count: int = 0
var is_dash_used: bool = false

var checkpoint: Vector2

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer_label: Label = $HUD/Timer

@export var unlock_all_abilities: bool = false

var abilities: Dictionary = {}
var watermelons: int = 0

var elapsed_time: float = 0.0

func _ready() -> void:
	if unlock_all_abilities:
		abilities = {
			"double_jump": true,
			"dash": true
		}
	
	start_timer()

func _process(delta: float) -> void:
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
	print(watermelons)

func start_timer():
	elapsed_time = 0.0
	update_timer_display()

func update_timer_display():
	var minutes = int(elapsed_time / 60)
	var seconds = int(elapsed_time) % 60
	var milliseconds = int((elapsed_time - int(elapsed_time)) * 100)
	timer_label.text = "%d:%02d:%02d" % [minutes, seconds, milliseconds]
