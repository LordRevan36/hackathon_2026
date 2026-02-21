extends RigidBody2D

@onready var collision_shape = $CollisionShape2D
@onready var sprite = $Sprite2D
@onready var floor_check = $FloorCheck

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	state.angular_velocity = 0.0
	var target_angle = 0.0
	if floor_check.is_colliding():
		var surface_normal = floor_check.get_collision_normal()
		target_angle = surface_normal.angle() + (PI / 2.0)
	var current_angle = state.transform.get_rotation()
	var new_angle = lerp_angle(current_angle, target_angle, 0.2)
	state.transform = Transform2D(new_angle, state.transform.get_origin())
