@tool
extends Node2D

@export var centerKids : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if centerKids:
		_center_children()

func _center_children() -> void:
	for child in get_children():
		if child is platform:
			child._center_node()
	centerKids = false
