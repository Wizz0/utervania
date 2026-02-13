extends Node2D

@export var dimensions: Vector2i = Vector2i(15, 10)
@export var start: Vector2i = Vector2i(-1, 0)
@export var critical_path_length: int = 8
@export var branches: int = 3
@export var branch_length: Vector2i = Vector2i(1, 4)

var branch_candidates: Array[Vector2i]
var level: Array

func _ready() -> void:
	init_level()
	place_entrance()
	generate_critical_path(start, critical_path_length, "C")
	generate_branches()
	print_level()

func init_level():
	for x in dimensions.x:
		level.append([])
		for y in dimensions.y:
			level[x].append(0)

func print_level():
	var level_str: String = ""
	for y in range(dimensions.y - 1, -1, -1):
		for x in dimensions.x:
			if level[x][y]:
				level_str += "[" + str(level[x][y]) + "]"
			else:
				level_str += " "
		level_str += '\n'
	print(level_str)

func place_entrance():
	if start.x < 0 || start.x >= dimensions.x:
		start.x = randi_range(0, dimensions.x - 1)
	if start.y < 0 || start.y >= dimensions.y:
		start.y = randi_range(0, dimensions.y - 1)
	level[start.x][start.y] = "S"

func generate_critical_path(from: Vector2i, length: int, marker: String):
	if length == 0:
		return true
	
	var current: Vector2i = from
	var direction: Vector2i
	match randi_range(0,3):
		0:
			direction = Vector2i.UP
		1: 
			direction = Vector2i.RIGHT
		2:
			direction = Vector2i.DOWN
		3:
			direction = Vector2i.LEFT
	for i in 4:
		if (current.x + direction.x >= 0 && current.x + direction.x < dimensions.x and
			current.y + direction.y >= 0 && current.y + direction.y < dimensions.y and
			not level[current.x + direction.x][current.y + direction.y]):
			current += direction
			level[current.x][current.y] = marker
			if length > 1:
				branch_candidates.append(current)
			if generate_critical_path(current, length - 1, "C"):
				return true
			else:
				branch_candidates.erase(current)
				level[current.x][current.y] = 0
				current -= direction
	direction = Vector2(direction.y, -direction.x)
	return false

func generate_branches():
	var branches_created: int = 0
	var candidate: Vector2i
	
	while branches_created < branches && branch_candidates.size():
		candidate = branch_candidates[randi_range(0, branch_candidates.size() - 1)]
		if generate_critical_path(candidate, randi_range(branch_length.x, branch_length.y), str(branches_created + 1)):
			branches_created += 1
		else:
			branch_candidates.erase(candidate)
