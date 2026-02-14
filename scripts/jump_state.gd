extends State
class_name JumpState

var is_jump_key_held : bool = false

func enter():
	super.enter()
	uter.velocity.y = -uter.jump_force
	uter.anim.play("jump")
	is_jump_key_held = true

func exit():
	is_jump_key_held = false

func process(delta: float):
	if Input.is_action_just_released("jump"):
		is_jump_key_held = false

	var direction = Input.get_axis("ui_left", "ui_right")
	
	if direction != 0:
		uter.velocity.x = direction * uter.speed
		uter.anim.scale.x = direction
	else:
		uter.velocity.x = 0
	
	# Если клавиша прыжка зажата, применяем гравитацию с меньшей силой для длинного прыжка
	if is_jump_key_held:
		uter.velocity.y += uter.gravity * 0.5
	else:
		uter.velocity.y += uter.gravity
	
	uter.move_and_slide()
	
	if uter.velocity.y >= 0:
		transitioned.emit(self, "Fall")
