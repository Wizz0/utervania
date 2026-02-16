extends StaticBody2D

@export var respawnable : bool = true
@export var respawn_time : float = 3.0

var disappear : bool = false
var time = 1
var initial_position : Vector2
@onready var timer = $Timer
@onready var parent = get_parent()

func _ready() -> void:
	set_process(false)
	initial_position = parent.position

func _process(delta: float) -> void:
	time += 1
	if parent:
		# Тряска
		parent.position += Vector2(0, sin(time) * 0.5)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Uter:
		disappear = false
		set_process(true)
		timer.start(0.7)

func _on_timer_timeout() -> void:
	if parent:
		if respawnable:
			if !disappear:
				disappear = true
				parent.enabled = false
				$Crack.visible = false
				$Crack2.visible = false
				parent.set_process(false) # отключаем физику
			
				await get_tree().create_timer(respawn_time).timeout # ждем respawn_time
				
				# восстанавливаем платформу
				parent.position = initial_position
				parent.enabled = true
				$Crack.visible = true
				$Crack2.visible = true
				parent.set_process(false)
				set_process(false)
		else:
			parent.queue_free()
			queue_free()
