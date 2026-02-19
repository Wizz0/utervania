extends Node
class_name StateMachine

@export var initial_state: State
var current_state: State
var states: Dictionary = {}

func _ready() -> void:	
	for child in get_children():
		if child is State:
			states[child.name] = child
			child.transitioned.connect(on_child_transition)
	
	if initial_state:
		initial_state.enter()
		current_state = initial_state

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.process(delta)
		current_state.physics_process(delta)

func on_child_transition(old_state, new_state_name):
	if old_state != current_state:
		return
	
	var new_state = states.get(new_state_name)
	
	if !new_state:
		return
	
	current_state.exit()
	current_state = new_state
	current_state.enter()
