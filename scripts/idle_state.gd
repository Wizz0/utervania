extends State
class_name IdleState

func enter():
	super.enter()
	uter.velocity.x = 0
	if uter.anim == null:
		await get_tree().process_frame
	uter.anim.play("idle")

func process(delta: float):
	if Input.get_axis("ui_left", "ui_right") != 0:
		transitioned.emit(self, "Run")
	
	if Input.is_action_just_pressed("jump"):
		transitioned.emit(self, "Jump")
		
	gravity()
	uter.move_and_slide()
	
	if !uter.is_on_floor():
		transitioned.emit(self, "Fall")
