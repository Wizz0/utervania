extends CharacterBody2D
class_name Uter

@export var speed: float = 200.0
@export var jump_force: float = 200.0
var gravity = 10
var jump_count: int = 0

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
