extends Area2D

#@export var SPRING_CONSTANT : float = 1.5
@export var MAX_JUMP_OUTPUT : float = 900.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _get_bounce_velocity(current_velocity: Vector2) -> Vector2:
	var bounce_vector = Vector2(current_velocity.x, -MAX_JUMP_OUTPUT)
	return bounce_vector
