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

var abilities: Dictionary = {}

func die():
	camera.screen_shake(5, 0.2)
	position = checkpoint

func save(new_checkpoint):
	checkpoint = new_checkpoint

#func has_ability(ability: String):
	
