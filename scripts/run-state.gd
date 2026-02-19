extends State
class_name RunState

func enter():
	super.enter()
	uter.anim.play("run")

func process(delta: float):
	var direction = Input.get_axis("ui_left", "ui_right")
	
	if Input.is_action_just_pressed("jump"):
		transitioned.emit(self, "Jump")
	
	if Input.is_action_just_pressed("dash") and uter.has_ability("dash"):
		transitioned.emit(self, "Dash")
	
	if direction != 0:
		uter.velocity.x = direction * uter.speed
		uter.anim.scale.x = direction
	else:
		uter.velocity.x = 0
		transitioned.emit(self, "Idle")
	
	gravity()
	uter.move_and_slide()
	
	if !uter.is_on_floor():
		transitioned.emit(self, "Fall")
