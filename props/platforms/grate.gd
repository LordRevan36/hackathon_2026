@tool
extends platform # inherits all variables and functions from platform script
class_name Grate

func _ready() -> void:
	if collision_shape:
		collision_shape.one_way_collision = true
