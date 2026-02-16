extends CharacterBody2D
class_name Uter

@export var speed: float = 200.0
@export var jump_force: float = 200.0
@export var dash_force: float = 550.0
var gravity = 10
var jump_count: int = 0
var is_dash_used: bool = false

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D


func die():
	print("You're dead")
	queue_free()
