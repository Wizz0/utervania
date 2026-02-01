extends State
class_name FallState

func enter():
	super.enter()
	uter.anim.play("fall")

func process(delta: float):
	var direction = Input.get_axis("ui_left", "ui_right")
	
	if direction != 0:
		uter.velocity.x = direction * uter.speed
		#player.anim.flip_h = direction < 0
		uter.anim.scale.x = direction
	else:
		uter.velocity.x = 0
	
	gravity()
	uter.move_and_slide()
	
	if uter.is_on_floor():
		transitioned.emit(self, "Idle")
