extends Path2D

@export var loop = true
@export var speed = 1.0
@export var speed_scale = 1.0

@onready var path = $PathFollow2D
@onready var anim = $AnimationPlayer

func _ready() -> void:
	if !loop:
		anim.play("move")
		anim.speed_scale = speed_scale
		set_process(false)

func _process(delta: float) -> void:
	path.progress += speed
