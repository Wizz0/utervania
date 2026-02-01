extends Node
class_name State

signal transitioned(state: State, new_state_name: String)
var uter: CharacterBody2D

func enter():
	uter = get_tree().get_first_node_in_group("uter")

func exit():
	pass

func process(delta: float):
	pass

func gravity():
	uter.velocity.y += uter.gravity
