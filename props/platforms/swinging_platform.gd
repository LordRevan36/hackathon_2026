@tool
extends Node2D

@onready var platform = $"Platform"
@onready var left_line = $"LeftLine"
@onready var right_line = $"RightLine"

@export var max_angle_degrees : float = 30.0
@export var swing_speed : float = 2.0
@export var swing_radius : float = 200.0
@export var phase_offset : float = 0.0

@export var updateRadius : bool = false
@export var updateLines : bool = false

var time_passed = 0.0
var current_velocity : Vector2 = Vector2.ZERO
var _last_platform_global_pos : Vector2 = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_update_plat_position()
	_update_lines()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		if updateRadius:
			_update_radius()
		if updateLines:
			_update_lines()
	else:
		_update_rotation(delta)
		_save_velocity(delta)

func _update_radius() -> void:
	if Engine.is_editor_hint():
		swing_radius = platform.position.y
		_update_plat_position()
		_update_lines()
	updateRadius = false

func _update_plat_position() -> void:
	platform._center_node()
	platform.position.y = swing_radius
	platform.position.x = 0

func _update_rotation(delta: float) -> void:
	time_passed += delta
	var sine_wave = sin(time_passed * swing_speed + phase_offset)
	var current_angle = sine_wave * max_angle_degrees
	rotation = deg_to_rad(current_angle)

func _update_lines() -> void:
	var plat_size = platform.collision_shape.shape.size
	platform._center_node()
	
	left_line.position = Vector2.ZERO
	left_line.points = PackedVector2Array()
	left_line.add_point(Vector2.ZERO)
	var left_end_point : Vector2 = platform.position + Vector2(-plat_size.x / 2, -plat_size.y / 2)
	left_line.add_point(left_end_point)
	
	right_line.position = Vector2.ZERO
	right_line.points = PackedVector2Array()
	right_line.add_point(Vector2.ZERO)
	var right_end_point : Vector2 = platform.position + Vector2(plat_size.x / 2, -plat_size.y / 2)
	right_line.add_point(right_end_point)
	
	updateLines = false

func _save_velocity(delta: float) -> void:
	# Calculate velocity by checking the distance moved this frame
	var current_global_pos = platform.global_position
	current_velocity = (current_global_pos - _last_platform_global_pos) / delta
	# Save this position for the next frame's math
	_last_platform_global_pos = current_global_pos
	platform.constant_linear_velocity = current_velocity

func _get_swing_velocity() -> Vector2:
	return current_velocity
