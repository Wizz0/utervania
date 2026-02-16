extends State
class_name DashState

var dash_timer: float = 0.0
@export var dash_duration: float = 0.2

var direction

func enter():
	super.enter()
	
	direction = Input.get_axis("ui_left", "ui_right")
	if direction == 0:
		if uter.anim.scale.x == -1.0:
			direction = -1
		else:
			direction = 1
			
	uter.anim.play("dash")
	uter.is_dash_used = true
	dash_timer = dash_duration

func process(delta: float):
	dash_timer -= delta
	if dash_timer <= 0:
		if Input.is_action_just_pressed("jump") and uter.jump_count < 2:
			transitioned.emit(self, "Jump")
		
		transitioned.emit(self, "Fall")

func physics_process(delta: float):
	if !uter.is_on_floor():
		uter.velocity.y = -uter.jump_force * 0.1 # чуть поднимаем персонажа
		
	uter.velocity.x = direction * uter.dash_force
	
	uter.move_and_slide()
