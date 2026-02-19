extends State
class_name FallState

func enter():
	super.enter()
	uter.anim.play("fall")

func process(delta: float):
	if Input.is_action_just_pressed("jump"):
		if uter.jump_count == 0:
			transitioned.emit(self, "Jump")
		if uter.jump_count == 1 and uter.has_ability("double_jump"):
			transitioned.emit(self, "Jump")
	
	if Input.is_action_just_pressed("dash") and !uter.is_dash_used and uter.has_ability("dash"):
		transitioned.emit(self, "Dash")

func physics_process(delta: float) -> void:
	var direction = Input.get_axis("ui_left", "ui_right")
	
	if direction != 0:
		uter.velocity.x = direction * uter.speed
		uter.anim.scale.x = direction
	else:
		uter.velocity.x = 0
	
	gravity()
	uter.move_and_slide()
	
	if uter.is_on_floor():
		uter.jump_count = 0
		uter.is_dash_used = false
		transitioned.emit(self, "Idle")
