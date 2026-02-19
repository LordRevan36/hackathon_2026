extends CharacterBody2D

@onready var monster_sprite = $"MonsterSprite"
@onready var jump_timer = $"JumpTimer"
@onready var active_timer = $"ActiveTimer"
@onready var collider = $"Collider" #disabled for now, until collisions necessary

enum State {WAITING, JUMPING}
var state : State = State.WAITING
var target : Node2D
var jump_duration


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	monster_sprite.play("climb")
	jump_timer.wait_time = global_monster.MONSTER_WAIT_TIME
	jump_timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if state == State.JUMPING:
		velocity += get_gravity() * delta
	move_and_slide()
	#if _check_if_at_target(target) and State.JUMPING:
		#_reset()

func _on_jump_timer_timeout() -> void:
	var time_needed = jump_to_target(_find_best_platform())
	if time_needed > 0.0:
		active_timer.wait_time = time_needed
		active_timer.one_shot = true
		active_timer.start()

func _find_best_platform() -> Node2D:
	var get_all_platforms = get_tree().get_nodes_in_group("platform_group")
	var possible_targets = []
	
	for prop in get_all_platforms:
		if prop.get_parent().is_in_group("swinging_platform"):
			continue
		var distance = global_position.distance_to(prop.global_position)
		var above : bool = global_position.y > prop.global_position.y
		var minDist : bool = distance > global_monster.MONSTER_MIN_JUMP_DISTANCE
		#var idealDist : bool = distance > MONSTER_IDEAL_JUMP_DISTANCE
		if above and minDist:
			if possible_targets.is_empty():
				possible_targets.push_front(prop)
			else:
				var y_dist = global_position.y - prop.global_position.y
				var alt_y_dist = global_position.y - possible_targets.get(0).global_position.y
				var ideal_dist = global_monster.IDEAL_JUMP_HEIGHT
				if abs(ideal_dist - y_dist) < abs(ideal_dist - alt_y_dist):
					possible_targets.push_front(prop)
				else:
					possible_targets.push_back(prop)
	if possible_targets.is_empty():
		return null
	
	return possible_targets.get(0)

func jump_to_target(target_node: Node2D) -> float:
	if target_node == null:
		return 0.0
	var start_pos = global_position
	var target_pos = target_node.global_position
	# Get the gravity magnitude (assuming standard positive Y gravity)
	var gravity = get_gravity().y
	# 1. Calculate the Peak Y (Highest point of the arc)
	#the "highest" point has the LOWEST Y value.
	# We take the minimum (highest) of start vs target, then subtract jump height.
	var highest_point_y = min(start_pos.y, target_pos.y) - global_monster.MIN_JUMP_HEIGHT
	# 2. Calculate Vertical Velocity (v_y)
	# Physics formula: v_y = -sqrt(2 * g * h)
	# h_up is the distance from START to PEAK
	var h_up = start_pos.y - highest_point_y
	# Safety check for gravity or height issues
	if h_up <= 0 or gravity <= 0:
		return 0.0
	var initial_v_y = -sqrt(2.0 * gravity * h_up)
	# 3. Calculate Total Air Time
	# Time to go UP to peak: t_up = sqrt(2 * h_up / g)
	var t_up = sqrt(2.0 * h_up / gravity)
	# Time to fall DOWN from peak to target: t_down = sqrt(2 * h_down / g)
	var h_down = target_pos.y - highest_point_y
	var t_down = sqrt(2.0 * h_down / gravity)
	var total_time = t_up + t_down
	# 4. Calculate Horizontal Velocity (v_x)
	# v_x = distance / total_time
	var displacement_x = target_pos.x - start_pos.x
	var initial_v_x = displacement_x / total_time
	# 5. Apply
	velocity = Vector2(initial_v_x, initial_v_y)
	state = State.JUMPING
	#target = target_node
	return total_time
	
#func _check_if_at_target(target_node) -> bool:
	#if not target_node:
		#return false
	#if target_node.global_position.is_equal_approx(global_position) and target_node.global_position.is_equal_approx(global_position):
		#return true
	#else:
		#return false
		
func _reset() -> void:
	state = State.WAITING
	jump_timer.wait_time = global_monster.MONSTER_WAIT_TIME
	jump_timer.start()
	velocity = Vector2.ZERO


func _on_active_timer_timeout() -> void:
	_reset()
